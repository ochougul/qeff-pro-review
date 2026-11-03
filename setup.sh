#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_source="$repo_root/skills/ochougul-pr-reviewer"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skill_dest="$codex_home/skills/ochougul-pr-reviewer"
verify_only="false"

if [[ "${1:-}" == "--verify" ]]; then
  verify_only="true"
elif [[ "${1:-}" != "" ]]; then
  echo "usage: $0 [--verify]" >&2
  exit 2
fi

if [[ ! -f "$skill_source/SKILL.md" ]]; then
  echo "skill source is missing: $skill_source/SKILL.md" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it, then run this script again." >&2
  exit 1
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "Sign in to GitHub with the GitHub CLI."
  gh auth login --hostname github.com
fi

github_login="$(gh api user --jq .login)"

if [[ "$verify_only" == "false" ]]; then
  mkdir -p "$skill_dest"
  cp -a "$skill_source/." "$skill_dest/"
fi

[[ -f "$skill_dest/SKILL.md" ]] || {
  echo "skill is not installed: $skill_dest/SKILL.md" >&2
  exit 1
}

if [[ "$verify_only" == "true" ]]; then
  echo "Verified ochougul-pr-reviewer for GitHub user $github_login at $skill_dest"
else
  echo "Installed ochougul-pr-reviewer for GitHub user $github_login at $skill_dest"
fi
