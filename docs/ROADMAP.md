# Trailomon roadmap

Updated October 31, 2026. Scope: one polished Windows expedition before new regions. The playable foundation already shipped in [PR 1](https://github.com/Chillysoop/trailomon/pull/1), including the complete route, the original manual battles, foraging, saves, and progression. The owner approved plan-1 P1–P5 (hosted revision 7); combat comes first, equipment follows its testing. Statuses describe shipped work, not approvals.

## Playable prototype

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S1 | Establish the owner's development and review workflow | Plan, roadmap, shared agent rules, durable memory, review server/template, answer bridge, and a working plan review; existing playable retained | Server unit tests; browser YES/NO/comment/autosave/FINISH and fallback tests; existing game checks; branch, PR, CI, and merge verified | done (PR #2) |
| S2 | Record repeatable bot playtests | A command plays full seeded runs and writes per-run outcomes, decisions, resource lows, waits, and stalls; baseline stored as evidence | Fixed-seed repeatability; original benchmark checks retained; deliberate stall/error reported with context | done (PR #10) |

## Core systems

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S3 | Implement automatic combat rules, P1 | Deterministic two-position encounters with six distinct behaviors and bounded triggers available to tests; existing manual saves still work | Pairing and trigger scenarios, fatigue and exhaustion, simultaneous effects, retreat, defeat, and unchanged results across replay | done (PR #4) |
| S4 | Put automatic combat into the playable journey, P1 | Setup preview, position selection, readable exchanges, pause/step/speed, withdrawal, result explanation, and safe old-save handling | Native input/UI checks, save/resume equivalence, complete peaceful and fighting runs, actual 1280 by 720 playtest | done (PR #4) |
| S5 | Tune combat against expedition needs, P1 | Several viable pairings, understandable costs, and reasons to choose peaceful options; findings in a review page | Bot comparisons plus new-player and expert playtests; no universal strongest pair or endless defensive stall | doing |
| S17 | Compare an authored guardian sequence, N3 / C2 | Optional developer encounter with cargo shove, warning and heavy rush; setup preview, compatible saves and comparison against current rules | Four-stage save/forecast regressions; actual rendered screens; fixed crews and matched full-journey continuations | done (PR #18) |
| S6 | Clarify bounded gathering, P2 / N4 | Existing foraging gives clear place, effort, depletion, carrying, and net-food feedback; hunting stays deferred under approved P2 | Resource accounting scenarios, depleted and full-load previews, player can explain the cost of a gathering day | done (PR #7) |
| S14 | Explain crew readiness and establish shared symbols, N2 / owner note | Canonical icon catalog and Journal guide; combat trigger reasons and energy costs; contextual travel-duty result | Shared-resolver forecast and threshold scenarios; native guide/input checks; actual Windows readability and combat playtest | done (PR #7) |

## Content

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S7 | Give the route an increasing sense of remoteness, P3 | Six distinct landmark treatments and concise lore within existing content; later scenes show fewer reliable signs and shelters | Route screenshot sequence, contrast and clipping checks, player recognizes last resupply and the upland commitment | done (PR #21) |
| S8 | Refine creature anatomy and shared poses, P4 — deferred to the owner-led art overhaul | Six coherent silhouettes at travel scale, including hollow Brindlehorn antlers and Reedskipper's paddle tail; reviewed asset records | Grayscale and roster comparison, wagon-scale inspection, pose consistency, original icon readability | todo |
| S9 | Evaluate a tiny equipment experiment, P5 / N7 | Three purchasable work items, one slot per companion, stopped-only swaps, travel/combat tradeoffs and compatible saves | 64 Lua checks, native persistence/GUI, targeted captures and 144 repeated full journeys; see WORK_ITEMS.md | done (PR #24) |
| S18 | Add condition reports at the two forks, N9 | Reliable terrain and labeled uncertain conditions support preparation, with less information deeper in wilderness | 70 Lua checks, native controls, four rendered views; no RNG consumption or save changes | done (PR #25) |
| S19 | Extend two roadside choices into later consequences, N10 | Two short chains within the event pool, one clear later consequence each | 77 Lua checks, native checkpoint/Continue checks, five rendered views | done (PR #27) |
| S20 | Add three optional journal aims, N11 | Two delivered departure pairs, both final paths across arrivals, peaceful arrival; permanent journal records only | 85 Lua scenarios, native saves/navigation, six rendered views | done (PR #28) |

| S22 | Habitat wildlife and species observations, W1/W2 | Three habitat sightings, distinct guide records, saved observations and result count | Eligibility/cooldown/replay scenarios, native save round trips, three rendered views | done (PR #33) |
| S23 | Courier practice and recognition, W3/W4 | One optional Mossbell spar and two personal meetings | Practice isolation, triggers, forecast/save replay and focused captures | done (PR #34) |
| S24 | Optional discovery-led profile, W5 | One chosen hauler, two early recruit paths, normal profiles preserved | Recruitment/food/capacity, native two-depot saves and 64 repeated full journeys | done (PR #35) |
| S25 | One learned habit per companion, W6 | Feat unlocks a depot-selected travel tradeoff | Exact costs/previews, native persistence, equipment and focused captures | done (PR #35) |
| S26 | Complete Discovery haulers and guide clues, D1/D2 | Optional missing-hauler invitations at Split Oak/Willowford, clear food/space costs, useful habitat and method clues | Both starters, retention, capacity/food rejection, pure guide reads, native saves and actual screens | done (PR #37) |
| S27 | Follow saved wildlife tracks, D3 | One optional day-and-meals search per stretch, fixed saved outcome, no rerolls or extra search loops | Saved plans/results, closure/hunger/death, 24 repeated full journeys and focused captures | done (PR #37) |

## Polish

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S10 | Finish sound, settings, and interface basics | Audio controls persist; sounds reviewed; focus, readable costs, disabled explanations, and timing consistent | Settings persistence, mouse/keyboard journeys, listening review, actual window inspection | todo |
| S15 | Make road decisions readable and reversible, J1–J4 | Free return before combat's first exchange; exact recruitment food outlook; three authored road receipts; remembered viewing speed | Repeated inspection/RNG, old-save and native persistence checks; actual setup/receipt/recruit/restart screens | done (PR #14) |
| S16 | Capture rendered test screens automatically, F1 | One CLI command opens isolated production UI fixtures, performs actions, saves 1280×720 PNGs and exits | Options/speed and combat setup/first-intent captures inspected; isolation regressions; no player-save access | done (PR #17) |
| S21 | Player clarity: consistent color and symbol meanings | Shared recognition palette, labeled Energy/Condition meters, clear crew points, depot pack costs and separate Pressure/Cover readings | 90 Lua scenarios including contrast and pack accounting; native persistence/GUI and buy/return controls; 12 actual rendered screens | done (PR #30) |
| S11 | Run a complete new-player and expert playtest | Report page separates already-fixed bugs from design proposals and reassesses the plan | Fresh-profile journey, resumed journey, failure/return path, optimized and exploit-seeking run; evidence images and metrics | done (PR #11) |

## Release

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S12 | Prepare a shareable Windows candidate | Rebuildable `builds/Trailomon-windows.zip` with controls, launch instructions, source revision, and known limits; no credentials or test profile | Clean extraction and launch, release renderer, save round trip, CI green, ZIP contents and provenance checked | todo |
| S13 | Publish the owner-approved release | Owner explicitly authorizes public publication of the tested candidate; release notes and download link match that artifact | Recheck approval, hash/revision, downloadable asset and launch instructions | todo |

## Working rules

October 31 post-creature audit: all S22–S25 are shipped. [Next discovery loop](../reviews/next-2.html) proposes only new D1–D5 choices, with D1→D2→D3 recommended. The owner then said proceed; D1–D3 are approved in chat and implemented as S26/S27. D4/D5 remain undecided. S5 tuning and S10 reliability remain authorized work; current saves/settings and tests work. Art stays deferred.

October 31 creature-direction brainstorm: [wild-1](../reviews/wild-1.html) proposes sightings, field observations and one courier spar, with later relationship/acquisition/growth options. [Integration analysis](CREATURE_ENCOUNTERS.md) distinguishes reusable systems from new work. The owner approved W1–W6 in hosted revision 7. S22–S25 schedule the bounded additions; existing balance/reliability work remains open.

October 31 minimal-text follow-up to S21: compact daily readings and shorter depot/camp/gathering guidance; latest road note only; live combat omits repeated setup descriptions. Keep all costs, warnings, action labels and guide/journal details. This is interface copy/layout work; S5 balance and S10 reliability gaps retain their status.

The October 30 [next-batch review](../reviews/next-1.html) received N1-N8 YES, reaffirmed at revision 37. The owner's comment made icon consistency and player clarity immediate priority: N2 and N4 shipped in PR #7, alongside the shared symbol system. S14 was appended without renumbering existing steps. PR #10 delivers N1's S2 measurement tool, including 120 journeys and 339 matched continuations repeated exactly. N3's guardian experiment shipped in PR #18. PR #20's N1/S5 bounded cost pass adopts it for new journeys with 3/6/1 energy costs; existing saves keep their rules. Broader S5 tuning remains unfinished; N7 equipment is complete; N6 art is deferred to the owner-led overhaul; N5/S7 scenery is implemented in this batch. N8 developer-role journeys shipped in PR #11; physical input, listening, pacing and native reliability remain S10 gaps. P1-P5 approvals remain in force.

The phase remains core systems. The [whole-trip review](../reviews/journey-1.html) records two actual developer-role deliveries (days 25 and 23), resume, settings, gathering and voluntary return. PR #11 delivers S11; S10 still holds a native activation crash, physical keyboard, listening and human pacing checks. The owner finished journey-1 revision 5 with J1–J4 all YES; PR #14 delivers that coherent clarity batch as S15. PR #17 delivers F1 captures; PR #18 delivers the N3 experiment and comparison, available in developer controls. The bounded S5 cost pass is implemented with 54 Lua tests, 7,200 guardian scenarios and 38 matched continuations. Full tuning remains open. N5/S7 now supplies six distinct landmark scenes, route-specific travel, last-shop/shelter cues, and lore. Per the owner’s October 31 direction, N6/S8 and dedicated animation/scenery polish are deferred. The N1 checkpoint froze the baseline before the N7 equipment experiment; broader S5 balance remains open. Hosted next-1 revision 42 approved N9 trail reports, N10 two event follow-ups and N11 three optional journal aims. The pre-equipment checkpoint is complete without a base combat buff; S9 is implemented and validated in PR #24. N9 reports are implemented in PR #25; N10 is implemented in PR #27; N11 journal aims are implemented in this batch. N8/S10 reliability and feel checks follow the meaningful gameplay batch. Reference bot results do not prove optimal balance or human pacing.

October 31 S5 checkpoint: [the broader comparison](BALANCE_STUDY.md) covers 4,032 journeys and 292 matched encounter starts, all replayed exactly. Exhausted-encounter escape, battle-entry readiness and terminal progress/save bugs are fixed and validated by 88 Lua scenarios, native persistence/36 GUI states and two actual captures. [Balance review](../reviews/balance-1.html) adds only two new decisions: E1 woodland gathering and E2 Slatewhorl terrain footing. Their values are not implemented yet. S5 remains doing; S10 reliability/feel checks remain open. No blanket combat/item buff or art work is included.

Ship one step or a coherent approved batch per PR, test it, and merge after CI passes. Update the status to `done (PR #n)` with the actual number. A later failure reopens the relevant work rather than leaving a misleading done status. Preserve published review codes when editing a page.

At phase boundaries and on "what's next," compare the actual build with [PLAN.md](PLAN.md). Check basic systems and failing tests, identify the real phase, and publish five to twelve options with three to six top picks. Read all saved answers before proposing or closing work. Owner comments override the initial descriptions.
