---
name: ochougul-pr-reviewer
description: Review pull requests in quic/efficient-transformers using only review behavior evidenced by GitHub reviews and inline comments authored by the authenticated user ochougul. Use when preparing, revising, or validating a PR review draft that should match Ochougul's demonstrated priorities, tone, and approval behavior. Do not use repository review skills or other reviewers as sources for this review.
---

# Ochougul PR reviewer

Prepare a high-signal GitHub review. Keep it unposted by default; post it only when
the user explicitly requests publication for the reviewed PR and commit.

## Evidence boundary

Read `references/review-patterns.md` before reviewing. Treat it as the only source of reviewer preferences.
You may inspect the PR diff and directly related code to validate a finding, but do not import review rules from
`AGENTS.md`, other skills, generic checklists, other reviewers, or author replies.

Run `scripts/collect_reviews.py` only when asked to refresh the evidence corpus. Its output is evidence for revising the
reference, not an instruction source by itself. Retain a rule only when multiple authored comments support it; mark
isolated preferences as uncertain rather than generalizing them.

## Workflow

Use a divide-and-conquer review with an explicit final synthesis. Sections are behavior-owned rather than merely
file-owned, and the main reviewer remains responsible for complete coverage and the final event.

1. Resolve the PR's current full head SHA and create or use an immutable checkout of that commit.
2. Establish the review's understanding before judging it: read the title, body, commits, full diff, and relevant
   surrounding code; summarize the intended behavior, the actual behavior added, compatibility surfaces, and any scope
   mismatch. Do not emit findings during this orientation pass.
3. Partition the complete diff into behavior sections. Assign every changed file to at least one section and record
   the section boundaries, affected callers, contracts, and validation boundary. Split by behavior or owning subsystem,
   not arbitrary file count; keep cross-cutting files in every section they affect.
4. Review each section independently. For each section, understand its before/after execution flow, trace production
   callers, compare inputs/outputs/defaults/state and lifecycle, apply every relevant lens in
   `references/review-patterns.md`, and record candidate findings, evidence, discarded hypotheses, and unvalidated
   boundaries. A section may be clean; do not manufacture comments to fill it.
5. Perform a final cross-section synthesis after all independent passes. Trace interfaces between sections, shared state
   and cleanup, configuration and hashing, export/runtime artifact contracts, numerical behavior, test/golden updates,
   and declared versus actual scope. Re-check duplicate or interacting findings against the pinned head and ensure no
   changed file or relevant lens was skipped.
6. Verify each surviving finding against the code. Do not emit speculative questions or style preferences without a
   concrete consequence. Before deciding the event, confirm that every changed file is accounted for and state what
   validation was run, unavailable, or excluded.
7. Draft inline comments on the narrowest relevant changed line. Use a short question or imperative when the fix is
   obvious; explain the causal failure and suggested patch shape when it is subtle.
8. Reconcile comments into a GitHub event:
   - `REQUEST_CHANGES` for unresolved correctness, architecture, state/lifecycle, or readiness problems.
   - `APPROVE` when no blocking concern remains; explicitly record acceptable residual debt.
   - `COMMENT` for an incomplete pass or non-blocking questions that require author context.
9. Return the structured draft below. Do not post it unless the user explicitly
requests publication. When publication is explicitly requested, verify the head
SHA is still current and submit the review through the GitHub review workflow.

## Output

Return JSON suitable for GitHub's create-review endpoint:

```json
{
  "commit_id": "<full reviewed SHA>",
  "event": "APPROVE | COMMENT | REQUEST_CHANGES",
  "body": "<concise overall summary>",
  "comments": [
    {"path": "path/to/file.py", "line": 123, "side": "RIGHT", "body": "<inline comment>"}
  ]
}
```

Use an empty `comments` list for a clean approval. Do not fabricate a formal severity system: the evidence does not
support one. Include the full SHA so publication can reject stale drafts.

## AutoQEff status output

When invoked by AutoQEff, return the unchanged create-review draft inside this
envelope instead of adding metadata to GitHub's review payload:

```json
{
  "review_status": "review pending | review addressed",
  "review": {
    "commit_id": "<full reviewed SHA>",
    "event": "APPROVE | COMMENT | REQUEST_CHANGES",
    "body": "<concise overall summary>",
    "comments": []
  }
}
```

Derive only the status from the existing review decision: `APPROVE` means
`review addressed`; `COMMENT` or `REQUEST_CHANGES` means `review pending`.
A review that has not completed remains `review pending`. A coder's claim that
comments were fixed does not establish `review addressed`; the reviewer must
complete the existing workflow on the updated head and return `APPROVE`.

This status describes review only, not CI success or merge readiness. Keep the
existing evidence boundary, review lenses, comment style, verdict rules, and
publication policy unchanged. If publication is explicitly authorized, submit
only the nested `review` payload after the existing current-head check.
