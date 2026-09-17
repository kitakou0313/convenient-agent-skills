#!/usr/bin/env bash
# Save a generated Markdown report to a timestamped, non-overwriting path under /tmp.
#
# Skill name is inferred from this script's own location (skills/<name>/scripts/save_report.sh),
# so this file is self-contained and can be copied as-is into any skill directory that follows
# that layout.
#
# Usage:
#   <this script> [--project <name>] [--input <file>]
#     --project <name>   Override the inferred target/project name.
#     --input <file>     Read Markdown content from <file> instead of stdin.
#
# Save path:
#   /tmp/<skill-name>/<project-name>/<timestamp>/report.md
#   (timestamp: YYYYMMDD-HHMMSS; a "-1", "-2", ... suffix is added on same-second collisions
#   so a rerun never overwrites a previous report)
#
# Output (single line JSON on stdout):
#   {"status":"ok","path":"/tmp/.../report.md"}
#   {"status":"error","reason":"mkdir_failed|write_failed|invalid_argument","message":"..."}
set -euo pipefail

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_name="$(basename "$(dirname "$script_dir")")"

project_override=""
input_file=""

while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      project_override="${2:-}"
      shift 2
      ;;
    --input)
      input_file="${2:-}"
      shift 2
      ;;
    *)
      printf '{"status":"error","reason":"invalid_argument","message":"%s"}\n' "$(json_escape "unknown argument: $1")"
      exit 2
      ;;
  esac
done

infer_project_name() {
  if [ -n "$project_override" ]; then
    printf '%s' "$project_override"
    return
  fi
  local top
  if top="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    basename "$top"
    return
  fi
  if [ -f package.json ]; then
    local name
    name="$(grep -m1 '"name"[[:space:]]*:' package.json | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
    if [ -n "$name" ]; then
      printf '%s' "$name"
      return
    fi
  fi
  if [ -f go.mod ]; then
    local module
    module="$(grep -m1 '^module ' go.mod | awk '{print $2}')"
    if [ -n "$module" ]; then
      basename "$module"
      return
    fi
  fi
  if [ -f pom.xml ]; then
    local artifact
    artifact="$(grep -m1 '<artifactId>' pom.xml | sed -E 's/.*<artifactId>([^<]*)<\/artifactId>.*/\1/')"
    if [ -n "$artifact" ]; then
      printf '%s' "$artifact"
      return
    fi
  fi
  basename "$(pwd)"
}

project_name="$(infer_project_name)"
project_name="$(printf '%s' "$project_name" | tr -c 'A-Za-z0-9._-' '_')"
[ -n "$project_name" ] || project_name="unknown-project"

timestamp="$(date +%Y%m%d-%H%M%S)"
base_dir="/tmp/${skill_name}/${project_name}/${timestamp}"

target_dir="$base_dir"
suffix=1
while [ -e "$target_dir" ]; do
  target_dir="${base_dir}-${suffix}"
  suffix=$((suffix + 1))
done

if ! mkdir_err="$(mkdir -p "$target_dir" 2>&1)"; then
  printf '{"status":"error","reason":"mkdir_failed","message":"%s"}\n' "$(json_escape "$mkdir_err")"
  exit 1
fi

report_path="${target_dir}/report.md"

if [ -n "$input_file" ]; then
  if ! write_err="$(cat "$input_file" > "$report_path" 2>&1)"; then
    printf '{"status":"error","reason":"write_failed","message":"%s"}\n' "$(json_escape "$write_err")"
    exit 1
  fi
else
  if ! write_err="$(cat > "$report_path" 2>&1)"; then
    printf '{"status":"error","reason":"write_failed","message":"%s"}\n' "$(json_escape "$write_err")"
    exit 1
  fi
fi

printf '{"status":"ok","path":"%s"}\n' "$(json_escape "$report_path")"
