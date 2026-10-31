# Two roadside follow-ups

2026-10-31: N10/S19 is delivered in PR #27 with two short consequences within the existing18-event pool. No new art, region or review decision. Closeout rechecked hosted next-1 revision42: all N1–N11 remain approved, without amendments.

- Tree/haul: Brindlehorn clears the trunk; road_cleared is saved. At the next reached landmark a following cart shares6 food, limited by carrying room after meals. road_repaid prevents a second reward. The reminder names the trunk and actual packed amount. Other tree choices do not earn this consequence.
- Axle/risk: the original12 damage is split into6 now and up to6 on the next moving day with rain or woodland/ridge/gorge terrain. axle_lashed clears after that single slip. Rest or smooth travel does not clear it. A completed camp repair (or proper axle event repair) prevents it. Crossing/camping days never trigger a road slip. Previously resolved older saves get no retroactive damage.

road_story is an optional saved text receipt. It pauses travel, survives reload, names the cause, and is also logged. A free Continue clears only the receipt, including at an ending. Two consequences on one arrival combine. Preview warns about the axle; Journey and Camp retain its repair reminder. Boolean flags and bounded receipt text are validated; new expeditions clear everything.

Validation:77 Lua scenarios including seven new cases; native serialization before/after both consequences; production event/resume/Continue keyboard callbacks; existing36 GUI states. Five real rendered screens inspected. Reference journey regressions still finish with the same delivery totals; policies now acknowledge free receipts (reference-v1+road-receipts). These are fixed policies, not optimal balance or a physical-input/listening playtest. One test weather seed initially produced rain; corrected to the intended clear-day fixture without changing game RNG.

Next approved work: N11/S20 optional journal aims. The Windows activation fault, physical keyboard, listening, human pacing and broader balance remain milestone work. Keep updates small and do not resend YES/NO pages: N10/N11 already have approval. No hosted review deployment is needed for this delivery. Screens and input hashes are in reviews/evidence/event-consequences-1.
