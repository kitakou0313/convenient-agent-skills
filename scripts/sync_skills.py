#!/usr/bin/env python3
"""Regenerate README.md skill listings/commands and Claude Desktop upload zips
from skills/*/SKILL.md. Run via .githooks/pre-commit, or manually.
"""
import re
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
DIST_DIR = REPO_ROOT / "dist" / "desktop-skills"
README = REPO_ROOT / "README.md"
REPO_URL = "https://github.com/kitakou0313/convenient-agent-skills"

MARKERS = {
    "LIST": ("<!-- SKILLS:LIST:START -->", "<!-- SKILLS:LIST:END -->"),
    "CODE": ("<!-- SKILLS:CODE:START -->", "<!-- SKILLS:CODE:END -->"),
    "DESKTOP": ("<!-- SKILLS:DESKTOP:START -->", "<!-- SKILLS:DESKTOP:END -->"),
}


def parse_frontmatter(skill_md: Path) -> dict:
    text = skill_md.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        raise ValueError(f"frontmatter not found: {skill_md}")
    fields = {}
    for line in match.group(1).splitlines():
        if not line or line[0] in " \t":
            continue
        key, sep, value = line.partition(":")
        if sep:
            fields[key.strip()] = value.strip()
    return fields


def collect_skills() -> list[dict]:
    skills = []
    for skill_dir in sorted(SKILLS_DIR.iterdir()):
        skill_md = skill_dir / "SKILL.md"
        if not skill_dir.is_dir() or not skill_md.exists():
            continue
        fields = parse_frontmatter(skill_md)
        skills.append(
            {
                "dir": skill_dir,
                "name": fields.get("name", skill_dir.name),
                "description": fields.get("description", ""),
            }
        )
    return skills


def build_list_block(skills: list[dict]) -> str:
    return "\n\n".join(f"### {s['name']}\n{s['description']}" for s in skills)


def build_code_block(skills: list[dict]) -> str:
    lines = ["```"]
    lines += [f"npx skills add {REPO_URL} --skill {s['name']}" for s in skills]
    lines.append("```")
    return "\n".join(lines)


def build_desktop_block(skills: list[dict]) -> str:
    lines = ["```", "cd skills"]
    lines += [f"zip -r {s['name']}.zip {s['name']}" for s in skills]
    lines.append("```")
    return "\n".join(lines)


def splice(content: str, key: str, block: str, indent: str = "") -> str:
    start, end = MARKERS[key]
    pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.DOTALL)
    if not pattern.search(content):
        raise ValueError(f"markers not found in README.md: {start} / {end}")
    if indent:
        block = "\n".join(f"{indent}{line}" if line else line for line in block.splitlines())
        end = f"{indent}{end}"
    replacement = f"{start}\n{block}\n{end}"
    return pattern.sub(lambda _match: replacement, content, count=1)


def build_zips(skills: list[dict]) -> None:
    if DIST_DIR.exists():
        for zip_path in DIST_DIR.glob("*.zip"):
            zip_path.unlink()
    DIST_DIR.mkdir(parents=True, exist_ok=True)
    for skill in skills:
        zip_path = DIST_DIR / f"{skill['name']}.zip"
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for file_path in sorted(skill["dir"].rglob("*")):
                if file_path.is_file():
                    arcname = Path(skill["name"]) / file_path.relative_to(skill["dir"])
                    zf.write(file_path, arcname)


def main() -> None:
    skills = collect_skills()

    original = README.read_text(encoding="utf-8")
    content = original
    content = splice(content, "LIST", build_list_block(skills))
    content = splice(content, "CODE", build_code_block(skills))
    content = splice(content, "DESKTOP", build_desktop_block(skills), indent="    ")

    if content != original:
        README.write_text(content, encoding="utf-8")
        print("README.md updated")
    else:
        print("README.md already up to date")

    build_zips(skills)
    print(f"Generated {len(skills)} desktop zip(s) in {DIST_DIR.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
