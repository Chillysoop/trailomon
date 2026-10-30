# Validation and gaps

2026-10-30 baseline: 17 Lua checks pass, including 80 strategy/seed journeys (37 delivered, 43 late) without resource-accounting failures or deadlocks. Native save/backup/recovery, 25 GUI states, and battle/modal/focus interaction checks pass. Latest setup verification used `tools/test.ps1 -Headless`; that does not inspect rendered pixels.

The earlier actual Windows expedition reached Lantern Reach on day 25 with 94% cargo and three companions. It covered combat win/withdrawal, battle restart, camp, shop, recruitment, river, replay, covered wagon, and early return. User confirmed physical F3 works. Tool-injected keys did not reach the engine; native handler checks cover routing but do not replace physical keyboard usability. Detailed record: `docs/VALIDATION.md`.

Known production gaps: current combat is manual; selected creature studies need anatomical distinction, consistent poses, and animation; audio needs a listening pass and user controls; extended new-player pacing has not been validated. New lore, regions, auto-battles, and equipment are proposals, not shipped features.

Review bridge: server integration and real headless Edge tests cover votes, note-only answers, autosave/reload, immediate FINISH, waiter delivery, stale writes, offline export/restore, and desktop/phone layouts. Review UI evidence stays under `.tools` until selected screenshots are attached to a PR.
