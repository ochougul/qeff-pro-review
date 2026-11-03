# Repository setup instructions

When the user asks to set up this repository or the PR reviewer skill, run
`./setup.sh` from the repository root. It installs Git, GitHub CLI, and Python
3 when missing, then installs the skill globally for both Codex and Claude
Code.

Do not run `gh auth login`, enter credentials, or authenticate on the user's
behalf. If GitHub CLI is not authenticated, tell the user to run exactly:

```bash
gh auth login --hostname github.com
```

After setup, the user can use the skill to review PRs in
`https://github.com/qualcomm/efficient-transformers`.
