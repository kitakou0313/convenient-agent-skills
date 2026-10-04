#!/usr/bin/env bash
# boiling-docs-core の情報保存テストを実行する。
# 各ケースの input.md（と任意の constraints.txt）を Agent に処理させ、expect.txt のアンカーが
# 出力の <draft> / <unresolved> に残っているかを機械照合する。
#
# 使い方: tests/boiling-docs-core/run.sh [-n 実行回数] [ケース名の先頭一致 ...]
# 環境変数: AGENT_CMD  プロンプトを標準入力で受け取り、応答を標準出力に返すコマンド（既定: "claude -p"）
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
skill_file="$repo_root/skills/boiling-docs-core/SKILL.md"
cases_dir="$script_dir/cases"
agent_cmd="${AGENT_CMD:-claude -p}"
runs=3

usage() {
  echo "Usage: $0 [-n runs] [case-prefix ...]" >&2
  echo "  AGENT_CMD: command reading the prompt from stdin (default: 'claude -p')" >&2
}

while getopts "n:h" opt; do
  case "$opt" in
    n) runs="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
filters=("$@")

case "$runs" in
  ''|*[!0-9]*|0) echo "-n must be a positive integer" >&2; exit 2 ;;
esac

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

matches_filter() {
  local name="$1" f
  [ "${#filters[@]}" -eq 0 ] && return 0
  for f in "${filters[@]}"; do
    case "$name" in "$f"*) return 0 ;; esac
  done
  return 1
}

# text 中の anchor の最初の出現位置を返す。無ければ -1
pos_of() {
  local text="$1" anchor="$2" prefix
  case "$text" in
    *"$anchor"*) prefix="${text%%"$anchor"*}"; echo "${#prefix}" ;;
    *) echo -1 ;;
  esac
}

# <tag>...</tag> の中身を返す。無ければ失敗
extract_tag() {
  local tag="$1" text="$2" open close rest
  open="<$tag>"
  close="</$tag>"
  case "$text" in
    *"$open"*"$close"*) ;;
    *) return 1 ;;
  esac
  rest="${text#*"$open"}"
  printf '%s' "${rest%%"$close"*}"
}

# 追加制約ファイルの有効行（空行と # で始まる行を除く）
constraint_lines() {
  grep -Ev '^([[:space:]]*#|[[:space:]]*$)' "$1" || true
}

build_prompt() {
  local case_dir="$1"
  cat <<EOF
あなたは以下のスキル定義（SKILL.md）に従って動作してください。

--- SKILL.md ここから ---
$(cat "$skill_file")
--- SKILL.md ここまで ---

## 対象文書

<document>
$(cat "$case_dir/input.md")
</document>
EOF
  if [ -f "$case_dir/constraints.txt" ]; then
    cat <<EOF

## 追加制約

$(constraint_lines "$case_dir/constraints.txt")
EOF
  fi
}

# 1回分の出力を expect.txt で照合し、"type<TAB>anchor<TAB>0|1" を標準出力に返す
#   draft_text:      <draft> の中身（must / may / any / order の照合対象）
#   unresolved_text: <unresolved> の中身（flag の照合対象）
#   leak_text:       内部ID漏洩の確認対象（<plan>・<draft>・<unresolved> を連結したもの）
check_run() {
  local expect_file="$1" draft_text="$2" unresolved_text="$3" leak_text="$4" format_ok="$5"
  local line key val ok parts p prev cur part any_hit

  printf 'format\t-\t%s\n' "$format_ok"
  if printf '%s' "$leak_text" | grep -Eq '(^|[^A-Za-z0-9])(IC[0-9]+|G[0-9]+|P[0-9]+[a-z]?|C[0-9]+|S[0-9]+)([^A-Za-z0-9]|$)'; then
    printf 'idleak\t-\t0\n'
  else
    printf 'idleak\t-\t1\n'
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    key="${line%%:*}"
    val="$(trim "${line#*:}")"
    case "$key" in
      must|may)
        if [ "$(pos_of "$draft_text" "$val")" -ge 0 ]; then ok=1; else ok=0; fi
        printf '%s\t%s\t%s\n' "$key" "$val" "$ok"
        ;;
      flag)
        if [ "$(pos_of "$unresolved_text" "$val")" -ge 0 ]; then ok=1; else ok=0; fi
        printf 'flag\t%s\t%s\n' "$val" "$ok"
        ;;
      any)
        any_hit=0
        IFS='|' read -ra parts <<<"$val"
        for part in "${parts[@]}"; do
          p="$(trim "$part")"
          if [ "$(pos_of "$draft_text" "$p")" -ge 0 ]; then any_hit=1; fi
        done
        printf 'any\t%s\t%s\n' "$val" "$any_hit"
        ;;
      order)
        ok=1
        prev=-1
        IFS='<' read -ra parts <<<"$val"
        for part in "${parts[@]}"; do
          p="$(trim "$part")"
          cur="$(pos_of "$draft_text" "$p")"
          if [ "$cur" -lt 0 ] || [ "$cur" -le "$prev" ]; then ok=0; fi
          prev="$cur"
        done
        printf 'order\t%s\t%s\n' "$val" "$ok"
        ;;
      *)
        echo "unknown expect key '$key' in $expect_file" >&2
        ;;
    esac
  done <"$expect_file"
}

write_report() {
  local name="$1" case_dir="$2" case_out="$3" status="$4"
  local report="$case_out/report.md" i run_files=()

  for i in $(seq 1 "$runs"); do run_files+=("$case_out/run-$i.check"); done

  {
    echo "# $name"
    echo
    echo "- 判定: **$status**（実行 ${runs} 回）"
    echo "- 必須アンカー（must / any / order / flag）の通過率が100%未満なら FAIL。may・idleak・format は記録のみ"
    echo
    echo "## アンカーの照合結果"
    echo
    echo "| 種別 | アンカー | 通過 | 各回 |"
    echo "|---|---|---|---|"
    awk -F'\t' '
      FNR == 1 { fidx++ }
      {
        k = $1 "\t" $2
        if (!(k in n)) { order[++c] = k }
        n[k]++; s[k] += $3
        marks[k] = marks[k] ($3 == 1 ? "○" : "×")
      }
      END {
        for (j = 1; j <= c; j++) {
          k = order[j]; split(k, kv, "\t")
          a = kv[2]; gsub(/\|/, "\\|", a)
          printf "| %s | `%s` | %d/%d | %s |\n", kv[1], a, s[k], n[k], marks[k]
        }
      }' "${run_files[@]}"
    echo
    echo "## 入力文書"
    echo
    echo '````markdown'
    cat "$case_dir/input.md"
    echo '````'
    if [ -f "$case_dir/constraints.txt" ]; then
      echo
      echo "## 追加制約（constraints.txt）"
      echo
      echo '````text'
      cat "$case_dir/constraints.txt"
      echo '````'
    fi
    echo
    echo "## 期待値（expect.txt）"
    echo
    echo '````text'
    cat "$case_dir/expect.txt"
    echo '````'
    for i in $(seq 1 "$runs"); do
      echo
      echo "## 生成文章 run-$i"
      echo
      echo '````markdown'
      cat "$case_out/run-$i.draft.md"
      echo
      echo '````'
      echo
      echo "<details><summary>方針サマリ・未確定事項 / 生の応答は run-$i.md</summary>"
      echo
      echo "方針サマリ（plan）"
      echo
      echo '````markdown'
      cat "$case_out/run-$i.plan.md"
      echo
      echo '````'
      echo
      echo "未確定事項（unresolved）"
      echo
      echo '````markdown'
      cat "$case_out/run-$i.unresolved.md"
      echo
      echo '````'
      echo
      echo "</details>"
    done
  } >"$report"
}

# 全ケースを実行
ts="$(date +%Y%m%d-%H%M%S)"
out_root="$script_dir/out/$ts"
mkdir -p "$out_root"
summary="$out_root/summary.tsv"
printf 'case\tstatus\tmust\torder\tany\tflag\tmay\tidleak_ok\tformat_ok\n' >"$summary"
any_fail=0
ran=0

for case_dir in "$cases_dir"/*/; do
  name="$(basename "$case_dir")"
  matches_filter "$name" || continue
  if [ ! -f "$case_dir/input.md" ] || [ ! -f "$case_dir/expect.txt" ]; then
    echo "skip $name: input.md / expect.txt not found" >&2
    continue
  fi
  ran=$((ran + 1))
  case_out="$out_root/$name"
  mkdir -p "$case_out"
  build_prompt "$case_dir" >"$case_out/prompt.txt"

  for i in $(seq 1 "$runs"); do
    echo "[$name] run $i/$runs" >&2
    raw="$case_out/run-$i.md"
    if ! eval "$agent_cmd" <"$case_out/prompt.txt" >"$raw" 2>"$case_out/run-$i.err"; then
      echo "[$name] run $i: agent command failed (see run-$i.err)" >&2
      : >"$raw"
    fi
    raw_text="$(cat "$raw")"
    format_ok=1
    draft="$(extract_tag draft "$raw_text")" || { draft="$raw_text"; format_ok=0; }
    plan="$(extract_tag plan "$raw_text")" || { plan=""; format_ok=0; }
    unresolved="$(extract_tag unresolved "$raw_text")" || { unresolved=""; format_ok=0; }
    [ -n "$raw_text" ] || format_ok=0
    printf '%s\n' "$draft" >"$case_out/run-$i.draft.md"
    printf '%s\n' "$plan" >"$case_out/run-$i.plan.md"
    printf '%s\n' "$unresolved" >"$case_out/run-$i.unresolved.md"
    check_run "$case_dir/expect.txt" "$draft" "$unresolved" "$plan
$draft
$unresolved" "$format_ok" >"$case_out/run-$i.check"
  done

  # 種別ごとの通過数/総数を集計し、必須系に1つでも未通過があれば FAIL
  stats="$(cat "$case_out"/run-*.check | awk -F'\t' '
    { s[$1] += $3; n[$1]++ }
    END {
      split("must order any flag may idleak format", types, " ")
      for (j = 1; j <= 7; j++) {
        t = types[j]
        printf "%s%d/%d", (j > 1 ? "\t" : ""), s[t] + 0, n[t] + 0
      }
      printf "\n"
    }')"
  status=PASS
  for t in 1 2 3 4; do
    cell="$(printf '%s' "$stats" | cut -f"$t")"
    [ "${cell%/*}" = "${cell#*/}" ] || status=FAIL
  done
  [ "$status" = PASS ] || any_fail=1
  printf '%s\t%s\t%s\n' "$name" "$status" "$stats" >>"$summary"
  write_report "$name" "$case_dir" "$case_out" "$status"
done

if [ "$ran" -eq 0 ]; then
  echo "no cases matched" >&2
  exit 2
fi

echo
column -t -s "$(printf '\t')" "$summary"
echo
echo "出力先: $out_root"
echo "生成文章の確認: $out_root/<case>/report.md"
exit "$any_fail"
