# Expedition balance checkpoint

October 31, 2026 · S5 · `balance-v1`. This is an automated strategy comparison, not a human playtest. The phase remains core systems; human pacing, listening, physical input and the recorded native activation crash remain S10 work.

## Findings

The journey supports different crew and equipment choices, but woodland's dependable payoff is weak and Slatewhorl struggles as the only hauler. Combat has useful pairings; these results do not justify another global combat buff. The owner review proposes two small changes, E1 and E2, without implementing their balance values yet.

All figures below use seeds 1–12 and all 12 legal two-species departure pairs, with every species already unlocked. Each row has 144 journeys. The peaceful strategy uses ready species assistance, then an affordable peaceful option, then withdrawal. Normal rations, standard wagon, meadow/ridge, steady pace, no items, ferry and draft-first combat order are the defaults. “Delivered” means on time; late arrival is still a completed journey. Rescued journeys are included in means.

| Configuration | On time | Late | Rescued | Mean day | Mean cargo |
| --- | ---: | ---: | ---: | ---: | ---: |
| Peaceful default | 77 | 63 | 4 | 26.54 | 85.71 |
| Fight when available | 73 | 65 | 6 | 26.94 | 74.80 |
| Peaceful, woodland/ridge | 27 | 107 | 10 | 28.02 | 84.88 |
| Peaceful, meadow/gorge | 25 | 98 | 21 | 28.45 | 84.85 |
| Peaceful, woodland/gorge | 2 | 105 | 37 | 29.77 | 84.16 |
| Peaceful, hurried | 127 | 17 | 0 | 23.79 | 79.74 |
| Peaceful, hurried + padded trace | 144 | 0 | 0 | 22.07 | 79.54 |
| Peaceful, steady + dry wrap | 93 | 50 | 1 | 26.01 | 85.77 |
| Peaceful, rope crossing | 68 | 70 | 6 | 27.02 | 71.22 |
| Peaceful, rope crossing + release rope | 65 | 75 | 4 | 26.85 | 78.50 |

### Routes and creatures

Woodland is longer (30 versus 27 distance), 10% slower, and offers the same base gathering yield of 10 as meadow. Its event opportunities do not reliably repay this under the sampled policy: woodland/ridge averages 1.48 days later. The gorge is also slower, but explicitly avoids ridge wear and hurried cargo loss; its shelter already has a mechanical tradeoff. Route choices change later event timing, so these full journeys are paired by initial seed, not identical later encounters.

Slatewhorl alone as hauler (with Bellmoth, Cindercoil or Loamling) delivers on time in 0/36 peaceful default journeys; 32 arrive late and four are rescued. Its flat 12% hauling slowdown stacks with woodland/gorge terrain. Reedskipper + Slatewhorl delivers 10/12 under the same policy: this does not show Slatewhorl is universally weak, only that its sole-hauler niche needs attention. Draft-first order also disadvantages its wagon-only combat ability; reverse-order variants are included in the raw evidence.

### Combat

The 292 natural encounter snapshots each continue with fighting, the best available peaceful choice and withdrawal, then resume the same parent policy. These are 146 scavenger starts and 146 guardians; starts from the two parent policies can overlap and are not independent trials. All sampled starts had a peaceful option.

At scavengers, fighting saves the immediate food offer but averages 6.22 cargo and 27.62 combined crew energy lost, versus no cargo and 4.48 food for peaceful resolution. Subsequent on-time arrivals are 89/146 after fighting versus 75/146 after peace, while mean ending cargo is lower (75.12 versus 81.06). Threshold-based arrival counts and mean days measure different outcomes.

At guardians, fighting averages 8.88 immediate cargo lost and 0.69 days spent; peace loses no cargo and spends 0.64 days. Subsequent on-time arrivals are 84 versus 88. Yet Brindlehorn + Cindercoil repels all 12 sampled guardians without an immediate cargo loss or detour, whereas its peaceful choice takes a detour in all 12. Crew abilities and positioning matter. There is no evidence here for making every fight preferable to avoidance.

### Equipment

Items are purchased at their actual price and carried at their actual weight. The padded trace's benefit is concentrated in hurried hauling; at steady pace it does not improve the peaceful default outcome and still costs 12 coins. Hurried travel buys time at the cost of ridge cargo. The dry wrap reduces weather fatigue. Release rope improves mean cargo by 7.28 in the risky-crossing cohort, but does not guarantee earlier delivery. Keep these distinct purposes; no blanket item adjustment is proposed.

## Bugs already fixed

- An exhausted crew without an affordable food offer could have every scavenger choice disabled. The encounter page now exposes the existing withdrawal action, using the same costs and no combat exchange.
- Battle entry still demanded six energy while setup accepted three (four for legacy saves). Both now use the journey's actual combat rule.
- A travel day that overshot a landmark and triggered rescue could leave progress above distance, producing an invalid ending save. Progress now clamps before terminal checks; rescue still takes precedence over arrival awards.

Validation: 88 Lua scenarios, native save/load and 36 native GUI states passed. Added regressions cover both encounter types, equipment costs, legacy readiness, hunger/closure at intermediate/final landmarks, deterministic replay and native persistence. Two actual 1280×720 release-rendered captures verify the escape choice and closure ending. This does not verify physical keyboard input or audio.

## Reproduction and limits

Run `python tools/balance_study.py --seeds 12 --output reports/balance-new` from the repository after provisioning the pinned Lua runtime with `tools/test.ps1`. Use a fresh output folder. This reuses the full-expedition report runner and checks every command/save state; it is not a second game implementation.

The batch covers 4,032 full journeys (12 pairs × 28 configurations × 12 seeds) and 876 matched continuations. Every trace and ending is replayed and compared exactly: 9,816 executions, all completed. Three workers took approximately 101 seconds. The manifest records base commit `13479b1`, the dirty working tree and hashes of every simulation, content, save, policy and runtime input. Its hashes, rather than that base SHA alone, identify this pre-commit fixed source. The study fails if these inputs change during execution.

The visible-state bot rotates tired draft companions, uses fixed pace/routes/positions and existing resource thresholds. It has no RNG lookahead or optimization. This is a veteran-depot, two-member cohort; single-creature, recruited third-member, covered wagon, sparse rations, combined equipment and adaptive human strategies are not covered. Twelve fixed seeds are descriptive evidence, not a population estimate or proof of optimal balance. Human enjoyment and 20–35 minute pacing remain unmeasured.

Evidence: [summary tables](../reviews/evidence/balance-1/summary.json), [manifest](../reviews/evidence/balance-1/manifest.json), [complete compressed results and sample traces](../reviews/evidence/balance-1/results.json.gz), [withdrawal screenshot](../reviews/evidence/balance-1/exhausted_encounter.png), [ending screenshot](../reviews/evidence/balance-1/closure_arrival.png). New decisions: [E1/E2 owner review](../reviews/balance-1.html).
