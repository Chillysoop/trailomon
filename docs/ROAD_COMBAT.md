# Road combat / S30

Implemented November 1, 2026. New expeditions carry `wagon-road-v1`. Existing journeys without that marker retain their original manual/automatic combat until completion; the next expedition adopts the new rules. Mara remains a safe practice drill. Six species remain implemented.

## Consequences

Scavenger and territorial event choices open the actual traveling crew on the wagon battlefield. Existing encounter selection, quiet-day spacing, peaceful alternatives, recruitment and departure limits are unchanged. Fixed scavenger opponents have 110/60 HP; ridge opponents have 184/108 HP. This does not scale enemies to your party size.

All one to three traveling creatures appear; companions without 6 Energy or positive Condition sit out. Their condition is not lost. Setup shows Energy; Start is disabled when nobody can fight or wagon integrity rounds below one. Withdrawal remains available without supplies. Crew HP derives from existing Condition; wagon HP derives from real integrity. Fractional starting values are preserved by applying net HP changes, not replacing Condition with a rounded starting ratio.

Formation and carried equipment may be inspected freely. Back returns the same event and rolls before the first attack, ability or supply use. Start locks setup; the first committed action charges 6 Energy per participating creature once. No per-hit fatigue. A pre-action withdrawal has no combat effort charge. Actual attacks/skills mark the existing peaceful-journey aim; inspection does not.

Pause permits at most one carried medicine (+28 creature HP, capped, living wounded target only) and one repair (+20 wagon, capped). Empty inventory grants no charge. Supplies are deducted once when used. Calling for help mid-fight also retains injuries already taken. The result applies HP/Condition and wagon changes once, including medicine/repair gains. There is no hidden cargo damage from ordinary wagon hits. Defeat, stalemate or retreat uses the existing explicit consequence: scavengers take up to 8 food and cargo (4 with the existing rope benefit), or a territorial detour takes one day, meals and weather. Victory grants no invented supplies or currency. Contribution and net-resource receipts explain the result; Continue cannot charge twice.

The journey checkpoint retains clocks, effects, targets, RNG, equipment, playback speed and fractional time. Load/focus loss pauses. The controller writes a complete candidate before replacing the live journey; failed writes pause and do not apply payments. Separate sample saves and old battles keep their original paths.

## Feedback and validation

Owner-requested motion: basic hits move the attacker forward up to 8 pixels; abilities lift it up to 6 pixels. Original sprites only. Pause freezes the accent, reduced motion removes it, and animation reads combat time without touching RNG or outcomes.

148 Lua scenarios pass, including new boundary/accounting, 1/2/3-creature checkpoint, empty-supply, disabled-wagon, speed/reload/focus, failed-save and deadline regressions. Native release-renderer checks cover both real depot files, mid-battle saves, result/backup recovery and actual GUI callbacks. Existing legacy scenarios now explicitly create pre-S30 journeys instead of accidentally testing the new rules. Five 1280×720 rendered states were inspected.

The deterministic comparison covers seeds 1–40, three fixed policies, Classic/Discovery, and previous/new combat: 480 journeys, each repeated exactly. All 80 peaceful comparisons have identical complete outcomes after removing only the version marker. Fighting policies encounter 33 battles in Classic and 29 in Discovery with either ruleset. New mean battle time is 14.7s / 16.5s of simulation (half at 2x). Classic deliveries rise from 9 to 13/40; Discovery from 4 to 6/40, but Discovery rescues rise from 0 to 2. Discovery wins 19/29 fights versus Classic 33/33. These are fixed, supply-free default-formation bots, not optimal strategies or human pacing. Solo combat needs further balance observation; no automatic buff was applied. The expedition reporter also replayed 93 whole/matched continuations exactly.

New-player developer lens: checked setup cost, actual names, readiness, ability feedback and result receipt. Added per-creature Energy/resting labels after the exhausted rendering looked like unexplained zero HP. Expert lens: checked free Back, save/retreat exploits, item ownership, repeated payments, empty supplies and resume equivalence. Actual GUI callbacks were exercised in the release renderer; physical input, listening, enjoyment and human pacing remain S10 limits. No claim of an independent human playtest.

Evidence: `reviews/evidence/road-combat/comparison.json` records source hashes and individual outcomes. Reproduce with `.tools/luajit-64.exe tools/road_combat_report.lua`; screenshots with `./tools/capture.ps1 -Scenes road_setup,road_fight,road_ability,road_result,road_exhausted`.
