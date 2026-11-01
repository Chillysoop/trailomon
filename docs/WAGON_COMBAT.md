# Astronarch-style combat, defending the wagon

Approved direction, November 1, 2026. The owner requested combat very close to Astronarch, then explicitly added the wagon as a defendable target. This supersedes the earlier two-position, shared-Resolve, three/four-exchange design and A1's narrower two-team experiment. The replacement is authorized; this document records the target. S28 is now an isolated playable sample; S29/S30 are still planned.

## The intended experience

Arrange a small creature team around the wagon, choose equipment and start combat. Individual creatures attack and use abilities automatically on their own clocks. Watch a prepared combination work, or see clearly why a defender, healer or disruptor was missing. Some enemies attack the crew; others try to reach the wagon. Winning quickly and protecting the delivery are competing priorities.

Keep Astronarch's attack-and-ability structure close. Our original species, ecology, supplies and wagon-defense objective give it a different identity. Oregon Trail still provides the journey, route choices, scarcity, recruitment opportunities and growing distance from support. Implement the mechanics in original Lua, using our existing art, creature names and independently authored abilities/items.

## Combat foundation

| Replace | Target |
| --- | --- |
| One combined enemy Resolve | Individual creature HP, defense, shields, status effects and target selection on both teams |
| A shared exchange counter | Independent basic-attack intervals and a separate automatically filling ability meter |
| One ability use per fight | Repeatable automatic active ability plus a passive identity for each species |
| Fixed approach/wagon roles | A compact front/rear formation that changes target exposure, interception and support |
| Three/four exchanges then forced result | Resolve when foes are driven off, the crew cannot continue, the wagon fails, or the player retreats; a separate generous technical stalemate guard prevents hangs |
| Tiny utility-only loadout | A small original equipment pool that changes attack, ability, defense or support behavior, acquired through travel/trade |

The developer's [Astronarch FAQ](https://steamcommunity.com/app/1234940/discussions/0/3112519935871524178/) confirms that attack timing and ability resources are separate: base MP accrues at 10 per second, attack intervals are bounded at 0.5–5 seconds, and the ability-cost floor is 10. Defense grants diminishing non-piercing mitigation (100 defense halves damage); shields absorb non-piercing damage and are capped by maximum HP. Use these verified relationships as initial reference constants. Status instances retain their source and duration. Our exact formation targeting, slot count, kit values and encounter balance must be documented and tested rather than presented as verified Astronarch parity. These values are starting points, not proof of equivalent feel.

The [developer's store description](https://store.steampowered.com/app/1234940/Astronarch/) establishes the larger purpose: skills, positioning and equipment create different party strategies. Build that decision loop with the current six species first. Content volume is not the acceptance criterion.

## The wagon is an objective, not another attacker

- Give the wagon its own visible integrity and shield state, separate from companion HP and ability meters. It does not attack, generate ability resource or take a creature slot.
- Ordinary enemy attacks prefer exposed front-line creatures. An enemy labeled **Raider** prefers the wagon; a living defender in the corresponding front position intercepts its ordinary attack. **Flanker** or **Ranged** exceptions must be visible before the fight, never hidden targeting surprises. These are Trailomon rules, not claims about Astronarch's exact targeting.
- A fallen defender opens a route to the wagon. Stun, distraction, attack-speed reduction and killing/driving off a raider can protect it as effectively as raw armor. Protection is a team-building choice, not a mandatory specific species.
- Creature heals target creatures. Wagon repair requires an explicit wagon-support ability or a limited supply item. Creature shields protect it only when the ability says so. Do not let a generic healer make every wagon encounter safe.
- Defeating all opponents while the wagon remains serviceable wins. Crew collapse, zero wagon integrity or withdrawal ends combat with an explicit result; no permanent death is implied. If wagon failure and the last enemy's defeat occur on the same simulation tick, wagon failure takes precedence.
- Wagon damage maps back to the existing wagon condition once. Cargo damage happens only through a declared cargo-raiding attack or a stated defeat consequence; never silently charge both wagon and cargo for one hit.
- Mara practice uses a separate practice wagon and temporary combat HP. It demonstrates the same rules while preserving real wagon/cargo/companion condition. Its advertised effort cost persists.

Example: a raider heads for the wagon while a rival disruptor slows its defender. Brindlehorn intercepts; Bellmoth interrupts the disruptor; Cindercoil converts a successful block into pressure on the raider. A faster damage team might end the fight earlier but risks more wagon damage. Both approaches need a viable matchup.

## Crew, supplies and presentation

Use up to all three traveling companions in the replacement model; one- and two-creature crews remain supported. This deliberately replaces the current two-active cap. Keep the three-companion expedition cap and current departure/recruitment rules until separate approvals change them.

Combat HP and ability resource must not be confused with travel energy. Use separate labeled readings; internal MP may be called Focus in the original creature fiction. Map starting/ending combat health to expedition condition, preserve energy/readiness implications, and preview a bounded encounter effort budget. Do not transplant the old per-exchange stamina charge onto every fast auto-attack. Exact fatigue conversion is an integration balance task, not a hidden new penalty.

Equipment should share the existing carried inventory, acquisition and weight rules, rather than create a second disconnected inventory. Extend a few original items toward meaningful combat interactions. Support optional limited supplies during combat with pause; basic attacks and skills never require manual input. Final slot count and consumption rules are implementation parameters to verify against the reference and the expedition economy.

Reuse current sprites, semantic icons and restrained scenery. Show each unit's health, attack timing, ability readiness and current target; emphasize the wagon's danger. Use short effect labels and readable target indicators. No dedicated animation or art-overhaul work is needed to prove the model. Do not add real-time movement controls, mandatory reflex inputs or more forced fights to create an impression of depth.

## Delivery sequence and acceptance

1. **S28: playable isolated combat slice.** One developer-accessible wagon ambush, two enemy roles, three original companion kits supporting two contrasting formations, independent attacks/repeating skills/passives, pause/speed and explicit results. Simulate both sides; protect a genuine wagon target. This is the next implementation step, not a further approval question.
2. **S29: team-build depth.** Complete all six kits, a small equipment/limited-supply sample, Mara practice, and comparisons showing at least two useful builds. Keep the current creatures and readable original presentation. Repeated attacks alone do not count as success.
3. **S30: expedition integration.** Replace new-run road encounters after the slice passes; retain old manual and automatic save completion paths. Map wagon, health, effort, supply and reward consequences once; test whole journeys and appropriate encounter frequency. Migration must not reinterpret a battle in progress.

For every step: deterministic simulation independent of rendering; saved unit clocks, targets, effect durations and RNG; bounded event processing and stalemate exits; pause/fast/reload equivalence; correct source attribution for reactions; no recursive proc loops; a defeat/retreat path even when supplies are empty. Render the actual game at 1280×720 and compare the two team plans. Human playtest acceptance: the player can explain who protected the wagon, why a skill repeated, why a build won/lost, and what they would change next time.

Keep S5 exploration/time balance in view. More forced fights must not worsen the current conflict between collecting and the delivery deadline. The former 15–20% attention target is provisional, not a constraint that justifies cutting this model back into three scripted exchanges. Measure human pacing before fixing a combat share.

A2 Discovery defaults, A3 Trust removal, D4 lineup variants and D5 collection aims are still separate unanswered choices. The owner's combat direction authorizes none of those automatically.

## Implemented S28 rules

Open F3 → Wagon ambush / new combat. The original three-kit sample lives in `content/ambush.lua` and `simulation/wagon_combat.lua`; it does not alter expedition combat. Two lanes each have a front and rear slot. Any living front occupant intercepts the lane-1 raider; ordinary crew attacks prefer same-lane fronts, other fronts, then rear opponents. Lumen’s skill explicitly prefers the caller. Position swaps are setup-only.

The deterministic step is 100 ms. Each live unstunned unit gains one Focus; separate attack clocks count down. Stun suspends both, slow halves attack-clock progress. Abilities resolve before basic attacks in saved unit order; KO cancels remaining actions. Reactions resolve last, at most once per source each tick, and cannot recursively trigger another reaction. End checks prioritize wagon failure, crew collapse, victory, then the 180-second stalemate escape. An initial seeded 0–0.3-second attack offset survives checkpoints.

Moss gains 55 extra DEF in front and repeatedly shields himself (22) and the wagon (8). Ember’s attack interval is 1.5 seconds in rear / 0.8 seconds in front, with an intercepted-hit follow-up and a repeated single-target skill. Lumen stuns the caller for 1.4 seconds and grants 6 Focus to the lowest-ready ally. Enemy ordinary attacks and their repeating rush/slow skills use individual HP and targets. Shields cap at maximum HP, do not repair lost integrity, and armor uses the reference diminishing-mitigation formula. No permanent death, cargo loss or travel Energy charge exists in this sample.

The `wagon_ambush_v1` checkpoint uses a separate file and backup inside the active save namespace. It retains the snapshot, RNG, effect sources/expirations, target IDs, attack clocks, Focus, speed and partial tick. Reload, focus loss and leaving the sample pause it. Save failures pause playback. The production journey schema is unchanged.
