# Automatic combat

2026-10-30: Owner explicitly requested implementation and clarified Astronarch is the stronger mechanical influence; Automon is for creature-party inspiration. Approved P1 covers two positions, six species, existing two encounters. Equipment remains the later P5 experiment.

Implemented on codex/automatic-combat: automatic-v1 battle records, approach/wagon roles, six bounded triggers, persistent costs, pause/step/speed, encounter reports, retained legacy manual resolver/UI. Exact rules are in docs/COMBAT_RULES.md. Ordinary energy 4; ability +8 once. Calm exchanges 5 seconds, brisk 1.5; menus/focus loss/load pause. Reserve companions have no hidden bonuses or battle memories.

29 Lua checks pass, including 360 combat cases, 80 baseline journeys (37 delivered / 43 late), 40 fighting-strategy journeys (5 delivered / 35 late), and checkpoint replays. A separate CSV has 5,760 encounters across all pairs/solos, two environments, energy 100/16, and seeds 1-20. These comparisons are tuning evidence, not final balance. Native persistence, result acknowledgement, 26 screen states, input routing, and real controller clock checks pass.

Found/fixed: multiple redraws in one frame could exceed the GUI node limit; the game controller now coalesces them. Combat does not advance automatically after a save error. Native test fixtures require an isolated trailomon_qa_ namespace; the owner's normal save stays untouched.

Current handoff: final human-style visual/mouse checks are pending. Local headless test engine raised a Windows Security prompt for trailomonchecks. Asked owner to Cancel; computer-use rules prohibit acting on it. Use release-renderer checks for future local fixtures; -Headless is for CI. An isolated scavenger game is open, using trailomon_qa_scavengers_20261030224811; a territorial fixture is ready as trailomon_qa_territorial_20261030225231. Do not call this shipped until visual review, PR checks/merge, and a clean Windows rebuild finish.
