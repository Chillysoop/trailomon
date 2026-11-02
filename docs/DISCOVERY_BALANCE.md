# Discovery recovery / S5

November 2, 2026. The owner requested solo Discovery starts, recovery costs and room to explore. This bounded pass changes new journeys' recovery, not enemy strength, encounter frequency, search costs or deadlines. S5 remains doing: this is reproducible balance evidence, not completed human pacing validation.

## Implemented

- A fed camp day restores up to **40 Energy / 20 Condition**, previously 25 / 8. Cold exposure, warmth, equipment, food requirements and caps still apply.
- A repair day gives the crew the same recovery while repairing up to 30 wagon. It still costs one day, meals and one repair material.
- Medicine retains its +35 target bonus and one day of camp recovery. No free healing action or supply refund was added.
- New Classic and Discovery journeys carry `camp-v2`. A save without that marker keeps its old recovery and repair behavior; the next expedition adopts the new rules. Unknown versions are rejected.
- Camp shows the active journey's values and the repair/rest combination. Existing resource icons and short labels are retained.

## What the comparison says

Seeds 1–24; both fresh Discovery haulers; ten fixed visible-state policies; previous/current recovery. 960 journeys, each repeated exactly. A separate Classic check adds 192 journeys, each repeated exactly: **2,304 executions** total. Each action passes save validation and loop detection. The previous version removes only the recovery marker, retaining S30 wagon combat.

| Policy / starter | Previous on-time | New on-time | Mean recovery days, before → after |
|---|---:|---:|---:|
| Two searches, adaptive pace, recruit / Brindlehorn | 13/24 | 20/24 | 1.67 → 1.25 |
| Two searches, remain solo / Brindlehorn | 12/24 | 19/24 | 1.67 → 1.38 |
| Two searches, remain solo / Reedskipper | 12/24 | 19/24 | 2.04 → 1.58 |
| Two searches, adaptive pace, recruit / Reedskipper | 24/24 | 24/24 | 0.04 → 0.04 |
| Two searches, meadow route, recruit / Brindlehorn | 20/24 | 24/24 | 1.63 → 1.25 |
| Two searches, adaptive pace / Classic | 16/24 | 21/24 | 1.50 → 1.08 |

In the first row, recovery meals drop from 6.67 to 5.00 per trip. Arrival averages 26.3 → 25.5 days. Average cargo falls 84.4 → 82.7 because changed pace/weather sequences can trade cargo for speed. Outcomes are not guaranteed to improve on every seed.

Selective exploration remains a meaningful choice. Two searches complete in all runs of those cohorts. Searching every available stretch produces about 4.5 searches and only 3/24 on-time Brindlehorn deliveries after the change. Reedskipper can rotate with the early Brindlehorn invitation and reaches 22/24 in its all-search cohort. These party differences deserve further observation. Steady woodland travel with two searches is still usually late (3/24 Brindlehorn; 2/24 Reedskipper). Padded trace remains useful without becoming a required item: the meadow/adaptive/recruit cohort succeeds without it.

## Solo combat and decisions

Early encounters retain their fixed opponents and peaceful exits. The selective policy avoids a fight until two companions have at least 50 Condition / 12 Energy; recruitment costs real food. This policy wins all its sampled fights. A fight-every-threat policy still loses early solo encounters even with carried supplies: combat is not automatically safe merely because the player can choose it. Better recovery gives a defeated hauler a paid route back onto the road; it does not grant solo parity with a formed crew.

The policy normally recruits, rotates available draft companions when the other has over 20 more Energy, uses medicine below 55 Condition, repairs below 35 wagon, and buys provisions at Mossbell. Adaptive pace means hurried at 35+ hauler Energy, otherwise steady. It follows at most two affordable clues on the Mossbell/Cairn stretches, or all eligible clues in the all-search cohort. It cannot inspect hidden track results or RNG. Default formation is retained; combat uses at most one carried medicine and repair. Variants test staying solo, fighting every threat, avoiding combat supplies, meadow travel and buying/equipping padded trace. All rations are normal. This is not optimal play or measured player time.

## Verification and reproduction

154 Lua scenarios pass, including fed/unfed recovery, caps, one-time costs, medicine/rest interaction, old/new checkpoint equivalence, unknown-rule rejection, closure and recovery after a real solo fight. Native release-renderer saves replay repairs/rest identically in both depots with old and new rules. Four actual 1280×720 screens cover a solo defeat, the production Rest and Repair buttons, and legacy camp values. The solo fixture puts Reedskipper in the rear to expose wagon damage; it is a regression case, not a recommended formation. No physical input, listening or human enjoyment claim.

Commands (use new output paths):

```powershell
.tools/luajit-64.exe tools/discovery_balance.lua reports/discovery-new.json 24 compare
.tools/luajit-64.exe tools/discovery_balance.lua reports/classic-new.json 24 compare classic
./tools/test.ps1 -Suite Game
./tools/capture.ps1 -Scenes discovery_camp,discovery_rest,discovery_repair,legacy_camp
```

Evidence and tested input hashes: `reviews/evidence/discovery-balance/manifest.json`, `comparison.json`, `classic.json`, four PNGs and their capture source manifest. Base is `4f317a1`; the manifest identifies the tested dirty game inputs. The decision policy is versioned independently from the frozen historical report policies.

Next: S10's actual journey/pacing check, then the already-approved S32 symbiotic pair. The older E1/E2 numerical proposals remain unanswered; this pass does not implement them. No additional art, enemy scaling, rewards or deadline extension.
