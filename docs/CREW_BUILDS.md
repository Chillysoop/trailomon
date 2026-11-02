# Six kits and wagon practice — S29

November 1, 2026. Play the free build sample through **F3 → Wagon ambush / new combat**. Select a preset, swap companions, move positions and cycle gear before starting. At Mossbell, **Mara's wagon drill** uses the actual traveling crew and carried work items. Starting costs **6 Energy per companion, once**; inspecting costs nothing. A companion needs positive Condition. The drill uses temporary full HP, a practice wagon and one borrowed medicine/repair charge. Real health, wagon, cargo, packed supplies and time are unchanged. No rewards or practice grinding. Existing road encounters stay on their old rules until S30.

## Kits and combinations

| Species | Repeating skill | Passive opportunity |
| --- | --- | --- |
| Brindlehorn | Shield self 22 and wagon 8 | +55 DEF in front; intercepts can trigger Cindercoil |
| Reedskipper | Hit raider 10, interrupt 0.6s, draw its next basic attack within 3s | Redirecting a hit advances its attack 0.5s, at most once per tick |
| Loamling | Hit 12, expose one foe to +25% harm for 3s | First basic hit on a new opening advances its next attack 0.5s |
| Bellmoth | Hit 8 and stun the disruptor 1.4s | Successful stun grants the least-ready ally 6 Focus |
| Cindercoil | Single-target hit 26 | Follow an ally's intercept; faster basics in front |
| Slatewhorl | Shield the least-protected other companion 22, itself if alone | Its own shield absorbing a hit grants 4 Focus, once per tick |

No type chart or creature-created terrain. Effects retain source and expiry. Redirects consume one basic attack, not a skill. Stable saved order breaks ties. Reactions never recursively trigger more reactions; fallen creatures cannot act. Combat still ends through victory, wagon loss, crew collapse, retreat or the 180s guard.

Existing work items keep their travel/legacy-combat rules. The replacement model adds: Padded trace grants 18 DEF and 3 Focus per intercepted-hit tick but slows basics 0.2s; Release rope adds 4 basic power against exposed foes but loses 5 DEF; Dry wrap grants 1 extra Focus each 0.4s while any living teammate has shield, but loses 2 basic power. One item per companion, one copy per item, setup-only changes. Practice borrows no equipment: it uses the same carried inventory and weight already paid for. Practice assignments are temporary. The developer sample loans all three objects.

Pause to use one medicine (+28 HP, capped, lowest-health living companion) or one repair (+20 wagon, capped). Controls show the actual gain and remaining charge; full targets do not spend a charge, and medicine cannot revive. Supplies are optional and do not stop automatic attacks/abilities from functioning.

## Comparison evidence

`tools/crew_build_report.lua`: seeds 1–24; same opponents, starting HP and supplies; no supply use; fixed formation; each run replayed from tick 37. "Gear" assigns trace/rope/wrap to preset members in order. These are deliberate loadouts, not an optimal search.

| Plan | Gear | Wins | Time | Wagon left | Mean crew HP |
| --- | --- | --- | --- | --- | --- |
| Guard | none | 24/24 | 15.0s | 100 | 86.5% |
| Guard | sample | 24/24 | 15.0–15.3s | 100 | 90.6% |
| Rush | none | 24/24 | 13.8–14.4s | 18–34 | 82.0% |
| Rush | sample | 24/24 | 14.4s | 18–26 | 79.3% |
| Open & punish | none | 24/24 | 14.5–15.9s | 100 | 71.8% |
| Open & punish | sample | 24/24 | 14.5–15.0s | 100 | 78.5% |

The guard/rush tradeoff persists. Equipment helps the control plan but the same item assignment makes rushing worse. All 20 trios also finish and replay identically across seeds 1, 7 and 23 (60 wins). This one approachable match does not prove broad balance, difficulty or enjoyment. S30 needs multiple road scenarios and whole-expedition pacing.

## Focused developer playtest and reliability

New-player lens: setup names the wagon threat, target lane, repeating Focus skills and item penalties. Existing icons, written resources and exact supply gains remain visible. Expert lens: the control result exposes Loamling openings, rope procs, Slatewhorl shields and wrap-triggered extra casts. Captures drive the production callbacks; this is not a physical-input or human-enjoyment claim.

134 Lua scenarios pass, including six-kit combinations, bounds, gear transfer/lock, supplies, once-only Energy, failed-save atomicity, custom names and old v1 replay. Native saved-practice round trips and controls pass alongside the original save/UI suite. Five actual 1280×720 screens are in `reviews/evidence/crew-builds/`; source hashes and matched-run data identify the tested inputs. The capture practice writer is injected in memory; it cannot write player data.

The old S28 resolver and content are frozen for `wagon-ambush-v1` checkpoints. New samples use v2. Practice is nested in the journey save, so its payment and battle checkpoint commit together; backups and profile separation remain intact. Existing manual and old automatic battles still complete. S10 physical keyboard/listening/human pacing/native activation investigation remains open. No art pass or public release is included.

## Combat presentation

Owner direction, 2026-11-01: follow Astronarch visually as well as mechanically. The shared woodland battlefield replaces combat cards. Staggered opposing formations, overhead HP/Focus/attack clocks, local damage/shield/cast feedback and a small crew-damage tally follow the hierarchy in [Astronarch's official screenshots](https://store.steampowered.com/app/1234940/Astronarch/). Our wagon stays behind the defenders. Existing creature art, prop and icon colors are reused; no reference art is shipped.

Click a creature or its name (or TAB / ENTER) for one compact inspector. Swap, position and gear controls operate on that selected crew member. The action log is optional. Pausing freezes the display; result screens clear transient hits and status notices. Long custom names shorten safely at UTF-8 boundaries. Selection and feedback never change deterministic combat or its RNG. Full names remain in the journey crew view.

Eight actual 1280�720 renders cover setup, swap, active combat, victory, wagon loss, Mara, the log and a long name. Native checks cover sprite selection, keyboard actions, supplies, log close/new-sample behavior and save/reload. A new pure presentation regression verifies feedback expiry and no simulation mutation. This is a focused presentation pass; creature animations and the larger art overhaul remain deferred.
