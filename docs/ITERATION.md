# Faster iteration

2026-10-30 owner direction: ordinary updates should take minutes rather than spending an hour on repeated verification and delivery ceremony. This is a workflow target, not a timing guarantee. Keep original visual identity, save safety and regression coverage.

The previous batch mixed two whole journeys, four follow-up changes, native crash investigation, repeated UI navigation, review publication and bookkeeping PRs. Local automated checks took seconds; no precise hour-by-hour attribution was recorded. Do not invent a percentage breakdown.

## Default checks

| Change | Run now | Reuse or defer |
| --- | --- | --- |
| Docs or build records | Links, diff and relevant facts | No game replay, native suite or player ZIP |
| Review prose | New page content/layout and a short isolated control smoke test | Existing storage/revision/backend tests when those inputs are unchanged |
| Review code/storage | Review tests plus affected isolated browser/API scenarios | Game tests/build |
| Simulation/combat/save | Game suite; save/native checks when the boundary changes | Unchanged art and unrelated screens |
| UI/icon/art | Controller/native checks and affected rendered screens at 1280×720 | Whole journeys and unrelated screenshots |
| Balance/pacing/route | Relevant fixed-seed comparisons, then a focused human-style playtest | Broad matrix and two-role complete journeys until a milestone |
| Release candidate | Full checks, fresh/resumed journeys, physical input/audio, clean archive | Nothing relevant to release quality |

Commands: `./tools/test.ps1 -Suite Game -SkipEngine`, `-Suite Game -Headless`, `-Suite Review`, `-Suite Report`. The default remains `All`. CI's explicit documentation/review classification is covered by regression tests; unknown paths and tooling changes run everything. One PR event runs CI; manual full verification remains available. New pushes cancel stale runs.

## Evidence and delivery

Use one feature branch/PR with its tests, review and memory. Push normally through Git; authenticated dry-run succeeded on 2026-10-30, so GitHub blob-by-blob uploads are unnecessary here. Do not install gh merely to push. The connector can still create/merge PRs.

Do not rerun a passed check after only changing unrelated prose. A changed dependency, engine version, rendering setup, save schema or tested action invalidates relevant evidence. Screenshots remain evidence of their exact source, not a blanket approval of future screens. Existing headless GUI fixtures construct screens and invoke callbacks without Computer Use; they cannot prove rendered appearance, physical keyboard delivery or audio quality.

Publish design decisions and milestone reports through the existing YES/NO pages. Batch cosmetic report updates. Do not redesign or retest the unchanged review engine for each prose edit. Once answers are consumed, poll at session start/closeout instead of repeatedly during unrelated implementation. Optional tooling reviews do not require an idle hour-long turn.

Build one shareable ZIP after a meaningful gameplay batch or on request. Generated `builds/Trailomon-windows.json` records the exact commit and dirty status. Record it locally promptly; fold durable post-merge provenance into the next substantive PR instead of generating a chain of documentation-only PRs. No public release without owner authorization.

## Optional next investment

The owner approved speed-1 F1 in chat. `./tools/capture.ps1` now captures actual Options and combat screens through a test-only release renderer; see [SCREENSHOTS.md](SCREENSHOTS.md). Inspect affected PNGs directly and add cases as features need them. F2 (stable launcher) and F3 (evidence-reuse ledger) remain unapproved. Return to approved gameplay rather than building the rest of the tooling backlog.
