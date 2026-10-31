# Iteration speed

2026-10-30: Owner said the previous update took around an hour and wants much faster updates, testing without Computer Use, batching technical work, and reusing unchanged verification. This supersedes the earlier habit of exhaustive manual navigation and immediate packaging/bookkeeping for every small change.

Adopted: command-line tests by suite, one CI run per PR revision with stale-run cancellation, explicit docs/review classification (unknown inputs keep full coverage), focused rendered screens for UI changes, and full journeys/balance/crash investigation only when relevant or at milestones. No tests removed. Fold notes into the feature PR; no follow-up PR just for the previous merge SHA. ZIP once per meaningful game batch/on request. Optional review questions do not hold a finished update idle for an hour.

Normal `git push --dry-run` succeeded with interactive prompting disabled. Use Git push; the prior per-file GitHub uploads were unnecessary overhead in the current environment. gh remains optional. CI create/merge still works through the connector.

Existing tests already run 45 Lua checks, native persistence and 36 GUI states without Computer Use. Headless GUI construction is not a rendered screenshot. Keep visual/focus/input/audio limitations honest. New speed-1 F1–F3 are optional tooling proposals, not prerequisites for the fast loop; do not start without the owner's votes. See ITERATION.md for the matrix and exact commands.
