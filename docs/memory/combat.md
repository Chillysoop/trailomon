# Automatic combat

2026-10-30: Owner explicitly requested implementation and clarified Astronarch is the stronger mechanical influence; Automon is for creature-party inspiration. Approved P1 covers two positions, six species, existing two encounters. Equipment remains the later P5 experiment.

Implemented on codex/automatic-combat: automatic-v1 battle records, approach/wagon roles, six bounded triggers, persistent costs, pause/step/speed, encounter reports, retained legacy manual resolver/UI. Exact rules are in docs/COMBAT_RULES.md. Ordinary energy 4; ability +8 once. Calm exchanges 5 seconds, brisk 1.5; menus/focus loss/load pause. Reserve companions have no hidden bonuses or battle memories.

29 Lua checks pass, including 360 combat cases, 80 baseline journeys (37 delivered / 43 late), 40 fighting-strategy journeys (5 delivered / 35 late), and checkpoint replays. A separate CSV has 5,760 encounters across all pairs/solos, two environments, energy 100/16, and seeds 1-20. These comparisons are tuning evidence, not final balance. Native persistence, result acknowledgement, 27 screen states, input routing, and real controller clock checks pass.

Found/fixed: multiple redraws in one frame could exceed the GUI node limit; the game controller now coalesces them. Combat does not advance automatically after a save error. Native test fixtures require an isolated trailomon_qa_ namespace; the owner's normal save stays untouched.

2026-10-30 actual playtests complete: new-player scavenger victory, pause/step, costs retained on return; expert three-creature setup, position swap, reserve preservation, Stone Shelter -> Warmth Display, quit/reopen at exchange 3 paused, withdrawal and one-time result acknowledgement. Evidence in reviews/evidence/combat-1-*.png. Mouse and rendered layout verified; injected keyboard still does not reach the app reliably, so native handler tests remain the keyboard evidence.

Additional fixed bug: input could arrive before a deferred first draw initialized buttons, causing startup errors/crashes. Initial draw is immediate; later redraws coalesce. Actual corrected launch and reopen both passed. Local headless checks triggered a Windows Security prompt; it was dismissed by the owner. Use release-renderer tests locally, headless in CI.

Current delivery: prepare the tested PR and private combat-1 report; merge after CI, then build a clean Windows bundle. S3/S4 are implemented; S5 remains tuning rather than claiming final balance. New C1-C4 are optional follow-ups, not a second approval request for existing P1-P5.
