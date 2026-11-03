#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause
#
# -----------------------------------------------------------------------------

"""Collect one authenticated user's QEfficient review corpus without mutations."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from collections.abc import Sequence
from pathlib import Path
from typing import Any

REPOSITORY = "quic/efficient-transformers"


def run(command: Sequence[str]) -> str:
    process = subprocess.run(command, capture_output=True, text=True, check=False)
    if process.returncode:
        raise RuntimeError(process.stderr.strip() or f"command failed: {' '.join(command)}")
    return process.stdout


def run_json(command: Sequence[str]) -> Any:
    return json.loads(run(command))


def paginated_api(path: str) -> list[dict[str, Any]]:
    output = run(["gh", "api", "--paginate", path, "--jq", ".[] | @json"])
    return [json.loads(line) for line in output.splitlines() if line]


def collect(login: str) -> list[dict[str, Any]]:
    pulls = run_json(
        [
            "gh",
            "search",
            "prs",
            "--repo",
            REPOSITORY,
            "--reviewed-by",
            login,
            "--limit",
            "1000",
            "--json",
            "number,url,createdAt,updatedAt",
        ]
    )
    corpus = []
    for pull in pulls:
        number = pull["number"]
        reviews = paginated_api(f"repos/{REPOSITORY}/pulls/{number}/reviews")
        comments = paginated_api(f"repos/{REPOSITORY}/pulls/{number}/comments")
        authored_reviews = [review for review in reviews if (review.get("user") or {}).get("login") == login]
        authored_comments = [comment for comment in comments if (comment.get("user") or {}).get("login") == login]
        if authored_reviews or authored_comments:
            corpus.append({**pull, "reviews": authored_reviews, "comments": authored_comments})
    return corpus


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent, text=True)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as output:
            json.dump(payload, output, indent=2, sort_keys=True)
            output.write("\n")
        os.replace(temporary_name, path)
    except BaseException:
        Path(temporary_name).unlink(missing_ok=True)
        raise


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    arguments = parser.parse_args()
    login = run_json(["gh", "api", "user"])["login"]
    corpus = collect(login)
    write_json(arguments.output, {"repository": REPOSITORY, "reviewer": login, "pull_requests": corpus})
    print(json.dumps({"output": str(arguments.output), "pull_requests": len(corpus), "reviewer": login}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
