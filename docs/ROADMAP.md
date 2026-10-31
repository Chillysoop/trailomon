# Trailomon roadmap

Updated October 30, 2026. Scope: one polished Windows expedition before new regions. The playable foundation already shipped in [PR 1](https://github.com/Chillysoop/trailomon/pull/1), including the complete route, the original manual battles, foraging, saves, and progression. The owner approved plan-1 P1–P5 (hosted revision 7); combat comes first, equipment follows its testing. Statuses describe shipped work, not approvals.

## Playable prototype

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S1 | Establish the owner's development and review workflow | Plan, roadmap, shared agent rules, durable memory, review server/template, answer bridge, and a working plan review; existing playable retained | Server unit tests; browser YES/NO/comment/autosave/FINISH and fallback tests; existing game checks; branch, PR, CI, and merge verified | done (PR #2) |
| S2 | Record repeatable bot playtests | A command plays full seeded runs and writes per-run outcomes, decisions, resource lows, waits, and stalls; baseline stored as evidence | Fixed-seed repeatability; existing eighty-run check retained; deliberate stall/error reported with context | doing |

## Core systems

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S3 | Implement automatic combat rules, P1 | Deterministic two-position encounters with six distinct behaviors and bounded triggers available to tests; existing manual saves still work | Pairing and trigger scenarios, fatigue and exhaustion, simultaneous effects, retreat, defeat, and unchanged results across replay | done (PR #4) |
| S4 | Put automatic combat into the playable journey, P1 | Setup preview, position selection, readable exchanges, pause/step/speed, withdrawal, result explanation, and safe old-save handling | Native input/UI checks, save/resume equivalence, complete peaceful and fighting runs, actual 1280 by 720 playtest | done (PR #4) |
| S5 | Tune combat against expedition needs, P1 | Several viable pairings, understandable costs, and reasons to choose peaceful options; findings in a review page | Bot comparisons plus new-player and expert playtests; no universal strongest pair or endless defensive stall | todo |
| S6 | Clarify bounded gathering, P2 / N4 | Existing foraging gives clear place, effort, depletion, carrying, and net-food feedback; hunting stays deferred under approved P2 | Resource accounting scenarios, depleted and full-load previews, player can explain the cost of a gathering day | done (PR #7) |
| S14 | Explain crew readiness and establish shared symbols, N2 / owner note | Canonical icon catalog and Journal guide; combat trigger reasons and energy costs; contextual travel-duty result | Shared-resolver forecast and threshold scenarios; native guide/input checks; actual Windows readability and combat playtest | done (PR #7) |

## Content

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S7 | Give the route an increasing sense of remoteness, P3 | Six distinct landmark treatments and concise lore within existing content; later scenes show fewer reliable signs and shelters | Route screenshot sequence, contrast and clipping checks, player recognizes last resupply and the upland commitment | todo |
| S8 | Refine creature anatomy and shared poses, P4 | Six coherent silhouettes at travel scale, including hollow Brindlehorn antlers and Reedskipper's paddle tail; reviewed asset records | Grayscale and roster comparison, wagon-scale inspection, pose consistency, original icon readability | todo |
| S9 | Evaluate a tiny equipment experiment, P5 | Approved experiment after combat tuning: one work-item slot and three objects with travel and encounter tradeoffs | Capacity and save tests, competing useful choices, no mandatory item or manufactured loot from wildlife | todo |

## Polish

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S10 | Finish sound, settings, and interface basics | Audio controls persist; sounds reviewed; focus, readable costs, disabled explanations, and timing consistent | Settings persistence, mouse/keyboard journeys, listening review, actual window inspection | todo |
| S11 | Run a complete new-player and expert playtest | Report page separates already-fixed bugs from design proposals and reassesses the plan | Fresh-profile journey, resumed journey, failure/return path, optimized and exploit-seeking run; evidence images and metrics | todo |

## Release

| ID | Goal and review link | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S12 | Prepare a shareable Windows candidate | Rebuildable `builds/Trailomon-windows.zip` with controls, launch instructions, source revision, and known limits; no credentials or test profile | Clean extraction and launch, release renderer, save round trip, CI green, ZIP contents and provenance checked | todo |
| S13 | Publish the owner-approved release | Owner explicitly authorizes public publication of the tested candidate; release notes and download link match that artifact | Recheck approval, hash/revision, downloadable asset and launch instructions | todo |

## Working rules

The October 30 [next-batch review](../reviews/next-1.html) received N1-N8 YES at revision 34. The owner's comment made icon consistency and player clarity immediate priority: N2 and N4 ship in PR #7, alongside the shared symbol system. S14 was appended without renumbering existing steps. N1 (S2/S5) expedition measurement is next; N3 guardian behavior, N5/N6 wilderness/art, N7 equipment after tuning, and N8 whole-journey usability remain approved and unfinished. P1-P5 approvals remain in force.

After the clarity batch, the refreshed audit keeps the phase at core systems. Recommended execution order: S2 reports (N1), S10/S11 whole-trip validation (N8), the approved N3 guardian experiment and evidence-led S5 tuning, S7/S8 identity work (N5/N6), then S9 equipment (N7). The six remaining options retain their original approval codes; N2/N4 are marked shipped. No additional scope or repeated approval is requested.

Ship one step or a coherent approved batch per PR, test it, and merge after CI passes. Update the status to `done (PR #n)` with the actual number. A later failure reopens the relevant work rather than leaving a misleading done status. Preserve published review codes when editing a page.

At phase boundaries and on "what's next," compare the actual build with [PLAN.md](PLAN.md). Check basic systems and failing tests, identify the real phase, and publish five to twelve options with three to six top picks. Read all saved answers before proposing or closing work. Owner comments override the initial descriptions.
