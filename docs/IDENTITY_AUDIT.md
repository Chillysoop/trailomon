# Expedition identity and combat audit

Later November 1 owner direction: the combat replacement is now authorized and expanded toward Astronarch's attack system with wagon defense. See [WAGON_COMBAT.md](WAGON_COMBAT.md). A1's narrower proposal below is historical; A2/A3 remain unanswered. The measurements describe the unchanged PR37 build.

November 1, 2026. Game source/build: `b8fcf2cb890c652a09e0fbe219e43ada9dbfec03` (PR #37). This is a source, rendered-evidence and deterministic simulation audit, not an independent human enjoyment study. No gameplay rules were changed.

## What it feels closest to

My design judgment is approximately **75% Oregon Trail / 25% creature-collection RPG** overall. These are descriptive estimates, not measured player percentages. Classic feels closer to 80/20; Discovery closer to 65/35. Astronarch is a reference for the combat subsystem, not a third percentage to add to those totals.

The expedition dominates because food, hauling, weather, cargo, repair, crossing, route choice and the delivery clock determine success. Creatures mostly solve expedition problems. Discovery now adds a chosen starter, habitat clues, optional searches, recruitment and a retained roster. Classic gives four of six species immediately. Collection remains shallow: six species, one individual per species, no move selection or evolution, mostly fixed roles, and little battle-driven development. Names, observations and memories add attachment, but they do not yet generate many different team builds.

The road and expedition economy are the strongest foundation. My target would be about **65/35 in perceived identity**, retaining Oregon Trail's structure while making the small crew more interesting to assemble and use. This does not require frequent forced fights, more meters or a larger bestiary.

## How much combat is actually present

Fresh measurement: eight policies × seeds 1–24 = **192 complete journeys**, each replayed exactly, using the current simulation and its existing validated report runner. Both classic and Discovery profiles are represented. All routes use woodland/ridge, normal supplies, no purchased work items, no learned habits, and a fixed visible-state policy. These are deliberately simple policies, not optimized players or a population sample.

| Policy / 24 runs each | Mean battles per journey | Range | Combat share of simulation commands |
| --- | ---: | ---: | ---: |
| Classic, peaceful | 0 | 0 | 0% |
| Classic, prefer road fights | 0.79 | 0–2 | 9.5% |
| Classic, prefer fights and accept Mara | 1.63 | 1–3 | 19.0% |
| Discovery Brindlehorn, peaceful | 0 | 0 | 0% |
| Discovery Brindlehorn, fights + Mara | 1.67 | 1–3 | 17.8% |
| Discovery Reedskipper, fights + Mara | 1.63 | 1–3 | 16.9% |
| Discovery Brindlehorn, also search every stretch | 1.42 | 1–2 | 13.5% |
| Discovery Reedskipper, also search every stretch | 1.54 | 1–3 | 14.4% |

Combat commands count opening practice, choosing a fight, starting, stepping, acknowledging and withdrawing. The denominator includes automatic travel-day commands and all accepted simulation commands. It excludes UI reading, menu browsing and position-selection clicks. **These percentages are not percentages of playtime or attention.** Eleven of 24 Classic fight-seeking journeys had no road fight. There are only two hostile encounter types and one optional practice encounter, each offered at most once per trip.

The current calm clock waits 20 seconds per travel day and 5 seconds per combat exchange. Battles last at most 3 exchanges, or 4 for the guardian: at most 15–20 seconds of automatic resolution, plus setup, reading and pauses. Across the fight-seeking cohorts, combat accounts for only **2.8–5.5% of the scheduled travel-plus-combat clock**. Brisk speeds and player pauses change this. Human playtime share is unmeasured; calling combat “20% of playtime” would be unsupported.

A proposed future target is **15–20% of active player attention**, with a viable peaceful route. That is a design target to test, not a claim about today's build. Depth per encounter should improve before frequency increases.

## Is it satisfying like Astronarch?

**Not yet, in my assessment.** It has useful preparation decisions, but the current model is closer to a short automatic wagon-defense puzzle than to a developed party-building autobattler.

What works: front/wagon positions matter; terrain and rain alter abilities; fatigue persists; Brindlehorn cover can enable Cindercoil's 20-pressure response. The earlier balance study found that pair repelled all 12 sampled guardians without cargo loss or a detour. That is evidence of a real interaction, not proof of universal balance. Peaceful alternatives and expedition costs give the encounter context.

What is missing:

- **An opposing team with individual behavior.** Mara's two creatures currently contribute to one Resolve bar and a fixed three-exchange script. There is no independent enemy condition, targeting or action clock.
- **Combinations that develop through a fight.** Most special abilities trigger once, after which ordinary pressure/cover does most of the work. Cindercoil's cover interaction shows the direction, but there are few alternatives of comparable depth.
- **Build-changing choices along the journey.** Three work items are useful travel tools; six habits mostly adjust travel costs. There is no sequence of skill/equipment decisions that substantially reshapes a combat plan.
- **A compelling reason to seek a rematch.** Practice costs energy for recognition and a result note. Hostile fights mostly avoid a payment or detour. More varied fights alone will not supply a satisfying preparation → demonstration → new choice loop.

[Astronarch's developer description](https://store.steampowered.com/app/1234940/Astronarch/) emphasizes differentiated hero skills, positioning, changing routes/opponents and items that alter a hero's role. Those interacting choices are the useful reference. We should build a small example of that depth rather than copy its content volume. Static captures and bots cannot certify enjoyment, audio impact or human pacing; those still need a focused player test.

## Systems to reconsider

| System | Recommendation | Evidence / boundary |
| --- | --- | --- |
| Shared enemy Resolve / fixed Mara script | Prototype an alternative for one encounter | Useful first implementation, but now the main constraint on two-team combat. Keep the current model until comparison justifies replacement. |
| Classic as the initial/default profile | Prefer Discovery for new players if collecting is central | Four starting species bypass most early acquisition. Preserve Classic and all existing saves. |
| Visible Trust 1–3 | Remove the number from the interface | It increments at journey commitment, even after difficult endings, and does not affect simulation decisions or abilities. It implies a relationship mechanic that does not exist. Keep names, temperament text and memories. |
| Current learned habits | Reconsider values and how they are earned | All unlock after three fed working travel days; most are energy savings with a supply/speed penalty. Earlier fixed-policy results worsened on-time arrival for the hauling habit. This is not proof every habit is bad; avoid adding more toggles until their distinct uses are demonstrated. |
| Full crew blocks recruitment | Revisit after the combat test | The cap is a good food/role tradeoff, but it also makes a wanted discovery unavailable. A future depot-only befriending option might preserve the field cap; not authorized here. |
| One-day searches versus delivery closure | Balance before expanding content | See matched-policy result below. Choosing a few detours should remain a decision; the game need not reward searching everything. |
| Manual combat implementation | Keep as save compatibility only | Older manual battles have a legitimate completion path. Delete only after an explicit tested migration and recovery plan. |
| Food, wagon wear, weather, crossings and quiet travel | Keep | These carry the Oregon Trail identity. Simplifying them away would weaken the intended game. |

### Discovery currently competes sharply with delivery

In matched whole-journey policies, enabling every available track search changed road-closure rescues from **1/24 to 18/24** with Brindlehorn, and **3/24 to 21/24** with Reedskipper. Both variants accept Mara and available hauler meetings; searches are the policy difference. Search-enabled runs averaged 4.5 searches. Aggregate: **4/48 → 39/48 closures**. Without searches, only 2/48 arrived on time; the steady woodland/ridge policy is already slow.

This identifies a conflict between the new invitation to explore and the existing delivery clock. It does not prove that four searches should be safe, that all humans will fail, or that searches alone cause all downstream losses. Searching changes time, food, encounters and subsequent choices. The current study uses one branch combination and unoptimized defaults. Authorized S5 work should compare zero, one and two targeted searches with pace/route adaptations before choosing a cost or deadline change. Do not quietly remove the deadline or make every search free.

## Revised recommendation

Prioritize one genuine two-team combat prototype and the already-authorized S5 exploration/time comparison. D4's extra scripted Mara lineups and D5's checklist aims remain open on their original page; this audit recommends delaying them while the more important gameplay question is tested. No previous approvals are revoked or inferred.

New decisions are **A1** one isolated two-team Mara prototype, **A2** Discovery as the default for new players, and **A3** remove the inert Trust number. See [the owner review](../reviews/identity-1.html). Do not implement these from this audit alone.

Evidence: [measurement script](../reviews/evidence/identity-1/measure.lua), [all 192 per-run records](../reviews/evidence/identity-1/results.json), [source manifest](../reviews/evidence/identity-1/source.json), [existing courier setup](../reviews/evidence/courier/courier_setup.png), [existing courier exchange](../reviews/evidence/courier/courier_active.png). The captures are prior actual release-renderer evidence; relevant UI inputs were checked for changes. Historical broad-balance results retain their original source/limits in [BALANCE_STUDY.md](BALANCE_STUDY.md).
