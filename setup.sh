#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_source="$repo_root/skills/qeff-pro-review"
codex_home="${CODEX_HOME:-$HOME/.codex}"
claude_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
codex_skill_dest="$codex_home/skills/qeff-pro-review"
claude_skill_dest="$claude_home/skills/qeff-pro-review"
verify_only="false"
required_tools=(gh git python3)

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

install_missing_tools() {
  local missing=()
  local tool
  for tool in "${required_tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    return
  fi

  if [[ "$verify_only" == "true" ]]; then
    printf 'missing required tools: %s\n' "${missing[*]}" >&2
    return 1
  fi

  local os
  os="$(uname -s)"
  if [[ "$os" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is required to install missing tools on macOS: https://brew.sh/" >&2
      return 1
    fi
    local brew_packages=()
    for tool in "${missing[@]}"; do
      if [[ "$tool" == "python3" ]]; then
        brew_packages+=(python)
      else
        brew_packages+=("$tool")
      fi
    done
    brew install "${brew_packages[@]}"
  elif [[ "$os" == "Linux" ]]; then
    local manager=()
    local install_args=()
    if command -v apt-get >/dev/null 2>&1; then
      manager=(apt-get)
      install_args=(install -y)
    elif command -v dnf >/dev/null 2>&1; then
      manager=(dnf)
      install_args=(install -y)
    elif command -v yum >/dev/null 2>&1; then
      manager=(yum)
      install_args=(install -y)
    elif command -v zypper >/dev/null 2>&1; then
      manager=(zypper)
      install_args=(--non-interactive install)
    elif command -v pacman >/dev/null 2>&1; then
      manager=(pacman)
      install_args=(-Sy --needed --noconfirm)
    elif command -v apk >/dev/null 2>&1; then
      manager=(apk)
      install_args=(add)
    else
      echo "No supported Linux package manager found; install these tools and rerun: ${missing[*]}" >&2
      return 1
    fi

    run_privileged() {
      if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
      elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
      else
        echo "sudo is required to install: ${missing[*]}" >&2
        return 1
      fi
    }

    if [[ "${manager[0]}" == "apt-get" ]]; then
      run_privileged apt-get update
    elif [[ "${manager[0]}" == "zypper" ]]; then
      run_privileged zypper refresh
    fi
    run_privileged "${manager[@]}" "${install_args[@]}" "${missing[@]}"
  else
    echo "Automatic tool installation is supported on Linux and macOS, not $os." >&2
    return 1
  fi

  for tool in "${missing[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Tool installation did not provide $tool; check your package manager and rerun." >&2
      return 1
    fi
  done
}

install_missing_tools

if [[ "$verify_only" == "false" ]]; then
  mkdir -p "$codex_skill_dest" "$claude_skill_dest"
  cp -a "$skill_source/." "$codex_skill_dest/"
  cp -a "$skill_source/." "$claude_skill_dest/"
fi

[[ -f "$codex_skill_dest/SKILL.md" ]] || {
  echo "skill is not installed for Codex: $codex_skill_dest/SKILL.md" >&2
  exit 1
}
[[ -f "$claude_skill_dest/SKILL.md" ]] || {
  echo "skill is not installed for Claude Code: $claude_skill_dest/SKILL.md" >&2
  exit 1
}

if [[ "$verify_only" == "true" ]]; then
  echo "Verified qeff-pro-review for Codex at $codex_skill_dest"
  echo "Verified qeff-pro-review for Claude Code at $claude_skill_dest"
else
  echo "Installed qeff-pro-review for Codex at $codex_skill_dest"
  echo "Installed qeff-pro-review for Claude Code at $claude_skill_dest"
fi

if gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "GitHub CLI is signed in; you can review PRs in qualcomm/efficient-transformers."
else
  echo "Setup is complete. To sign in on this machine, run:"
  echo "  gh auth login --hostname github.com"
fi
