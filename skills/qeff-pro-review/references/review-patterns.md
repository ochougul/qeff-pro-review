# Evidence-derived review patterns

These rules are derived only from reviews and inline comments authored by `ochougul` in
`quic/efficient-transformers`. The validated corpus contains 210 PRs, 768 review submissions, and 1,027 inline
comments spanning May 2024 through September 2026. Refresh the source corpus with `../scripts/collect_reviews.py`
before materially changing these rules.

## Review lenses

1. **Challenge unexplained scope.** Ask why unrelated changes are present and request removal when they are unnecessary.
   Evidence: [PR 1279](https://github.com/quic/efficient-transformers/pull/1279#discussion_r3850563319),
   [PR 1248](https://github.com/quic/efficient-transformers/pull/1248#discussion_r3902741773),
   [PR 1290](https://github.com/quic/efficient-transformers/pull/1290#discussion_r3879767026).
2. **Prefer reuse and deletion over duplication.** Reuse unchanged upstream or shared behavior and remove redundant
   wrappers, export paths, and checkpoint logic. Evidence:
   [PR 8](https://github.com/quic/efficient-transformers/pull/8#discussion_r1601389662),
   [PR 23](https://github.com/quic/efficient-transformers/pull/23#discussion_r1617018160),
   [PR 1290](https://github.com/quic/efficient-transformers/pull/1290#discussion_r3879235975).
3. **Keep one natural owner for behavior.** Put normalization, mutation, serialization, and configuration at the layer
   that owns them; avoid setting the same state in several places. Evidence:
   [PR 1178](https://github.com/quic/efficient-transformers/pull/1178#discussion_r3593940855),
   [PR 1290](https://github.com/quic/efficient-transformers/pull/1290#discussion_r3879168870),
   [PR 47](https://github.com/quic/efficient-transformers/pull/47#discussion_r1686322079).
4. **Keep interfaces minimal and compatible.** Scrutinize new interfaces, redundant parameters, changed defaults, and
   deprecations; prefer established call patterns and compatibility-preserving warnings. Evidence:
   [PR 1178](https://github.com/quic/efficient-transformers/pull/1178#discussion_r3593940855),
   [PR 1190](https://github.com/quic/efficient-transformers/pull/1190#pullrequestreview-3842453340).
5. **Trace silent correctness failures.** Treat ambiguous checkpoint selection, dropped weights, partial artifacts, and
   numerical behavior changes as blocking until proved safe. Evidence:
   [PR 1251](https://github.com/quic/efficient-transformers/pull/1251#discussion_r3761652137),
   [PR 1248](https://github.com/quic/efficient-transformers/pull/1248#discussion_r3904536479),
   [PR 1231](https://github.com/quic/efficient-transformers/pull/1231#discussion_r3862137232).
6. **Audit state and lifecycle.** Look for mutation by reference, state written before success, global or environment
   changes, cleanup ordering, and thread safety. Evidence:
   [PR 467](https://github.com/quic/efficient-transformers/pull/467#discussion_r2163294765),
   [PR 481](https://github.com/quic/efficient-transformers/pull/481#discussion_r2164152896),
   [PR 1290](https://github.com/quic/efficient-transformers/pull/1290#discussion_r3879799044).
7. **Check contract consistency.** Compare defaults, names, docs, examples, hashing, and runtime paths rather than
   reviewing each in isolation. Evidence:
   [PR 1138](https://github.com/quic/efficient-transformers/pull/1138#discussion_r3520262369),
   [PR 1289](https://github.com/quic/efficient-transformers/pull/1289#discussion_r3893772960),
   [PR 420](https://github.com/quic/efficient-transformers/pull/420#discussion_r2176579757).
8. **Demand evidence at the real boundary.** Ask for focused reproduction and the execution path affected by the
   change; for model changes, prefer HF-to-QEff-to-runtime parity. Evidence:
   [PR 1108](https://github.com/quic/efficient-transformers/pull/1108#discussion_r3656229707),
   [PR 1178](https://github.com/quic/efficient-transformers/pull/1178#discussion_r3593960001),
   [PR 10](https://github.com/quic/efficient-transformers/pull/10#discussion_r1597908439).
9. **Remove dead and repeated structure.** Request deletion of unused imports, commented-out code, pointless wrappers,
   and repeated code when the replacement is concrete. Evidence:
   [PR 1115](https://github.com/quic/efficient-transformers/pull/1115#pullrequestreview-4574056986),
   [PR 25](https://github.com/quic/efficient-transformers/pull/25#pullrequestreview-2115106485).
10. **Probe resource and shape boundaries.** Check device selection, memory, compilation, caching, and sequence-length
    cases where behavior may silently diverge. Evidence:
    [PR 1238](https://github.com/quic/efficient-transformers/pull/1238#discussion_r3913472703),
    [PR 1190](https://github.com/quic/efficient-transformers/pull/1190#pullrequestreview-3851290588).

## Comment and verdict style

- Use terse questions or imperatives for obvious edits: “why is this needed?”, “remove”, “revert”, or “move to top.”
- For subtle failures, state the consequence and give a concrete replacement or patch shape. Evidence:
  [PR 506](https://github.com/quic/efficient-transformers/pull/506#discussion_r2194541753) and
  [PR 1290](https://github.com/quic/efficient-transformers/pull/1290#discussion_r3879294488).
- Be direct and collaborative. Correct your own misunderstanding and invite alternatives when design constraints are
  uncertain. Evidence: [PR 479](https://github.com/quic/efficient-transformers/pull/479#discussion_r2166981576) and
  [PR 10](https://github.com/quic/efficient-transformers/pull/10#discussion_r1598643656).
- Prefer iterative line-level review over a long generic summary. Mark an incomplete pass as such rather than issuing a
  premature verdict. In the corpus, 125 of 210 PRs have multiple review submissions.
- Approval may include explicit residual debt or depend on CI. Request changes for unresolved correctness,
  architecture, missing tests, or readiness problems, but do not map review state to an invented severity count. The
  corpus contains 52 PRs that move from changes requested to approval after revision.

## Unsupported generalizations

Do not encode a blanket preference for one-line implementations, the word “slop” as normal tone, a fixed severity
taxonomy, or a rule that every test gap blocks approval. The observed reviews do not support those conclusions.
