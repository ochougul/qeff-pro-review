# QEff PR reviewer skill

This repository packages the `ochougul-pr-reviewer` Codex skill for the team.
The skill instructions, review evidence, helper script, and agent metadata are
under `skills/ochougul-pr-reviewer/`.

## Set up with a coding agent

From this repository's root, ask your coding agent:

```text
Set up this repo so I can review PRs in
https://github.com/qualcomm/efficient-transformers. Run ./setup.sh and install
the required tools if they are missing. Do not sign in to GitHub for me. When
setup is done, give me the login command to run on my machine if I am not
already signed in.
```

The setup script installs GitHub CLI (`gh`), Git, and Python 3 when needed on
Linux or macOS, then installs the skill globally for Codex and Claude Code
under `${CODEX_HOME:-~/.codex}/skills/` and
`${CLAUDE_CONFIG_DIR:-~/.claude}/skills/`. If GitHub CLI is not signed in, it
prints this one-time command for you to run:

```bash
gh auth login --hostname github.com
```

The script never starts the login flow or handles your credentials. Once
signed in, you can use the skill to review PRs in
`qualcomm/efficient-transformers`.

To verify the installation without copying the files again:

```bash
./setup.sh --verify
```

Set `CODEX_HOME` or `CLAUDE_CONFIG_DIR` if those tools use custom config
directories. The `--verify` option checks both global installations.

## Refresh review evidence

The optional corpus refresh script requires Python 3 and an authenticated
GitHub CLI session. It queries reviews authored by the currently signed-in
GitHub user in `quic/efficient-transformers`:

```bash
python3 skills/ochougul-pr-reviewer/scripts/collect_reviews.py --output review-corpus.json
```

The generated corpus is local user data and is ignored by Git. Review the
skill's evidence boundary before using or changing that corpus.
