# QEff PR reviewer skill

This repository packages the `ochougul-pr-reviewer` Codex skill for the team.
The skill instructions, review evidence, helper script, and agent metadata are
under `skills/ochougul-pr-reviewer/`.

## Set up on your machine

Install the GitHub CLI (`gh`) first. Then clone this repository and run the
setup script:

Replace `OWNER` with the GitHub account or organization that owns this repo.

```bash
gh repo clone your-org/qeff-pro-review
cd qeff-pro-review
./setup.sh
```

Replace `your-org` with the GitHub account or organization that owns this repo.

The script starts `gh auth login` if you are not already signed in to GitHub,
then installs the skill under `${CODEX_HOME:-~/.codex}/skills/`. GitHub CLI
keeps your login on your machine; credentials are not stored in this repo.
Restart Codex after setup so it discovers the skill.

To verify the installation without copying the files again:

```bash
./setup.sh --verify
```

Set `CODEX_HOME` if your Codex files live somewhere other than `~/.codex`.

## Refresh review evidence

The optional corpus refresh script requires Python 3 and an authenticated
GitHub CLI session. It queries reviews authored by the currently signed-in
GitHub user in `quic/efficient-transformers`:

```bash
python3 skills/ochougul-pr-reviewer/scripts/collect_reviews.py --output review-corpus.json
```

The generated corpus is local user data and is ignored by Git. Review the
skill's evidence boundary before using or changing that corpus.
