# Trailomon auto battles and gathering

Design proposal | October 30, 2026

Keep Oregon Trail's expedition structure and growing distance from dependable help. Use Astronarch as the primary combat reference to move combat decisions into crew selection, positioning, preparation, and useful combinations. A short automatic encounter should reveal how well that preparation suits the situation, with consequences that matter on the following travel days.

The owner clarified on October 30, 2026 that Astronarch is the primary reference for actual auto-battle mechanics; Automon informs creature-party identity. The first experiment is bounded to the existing six species and two encounter scenarios.

## Baseline before automatic combat

| System | Playable behavior |
| --- | --- |
| Battles | Two optional encounters: hungry Loamlings at the wagon and a territorial Slatewhorl on a narrow path |
| Control | Select one or two ready companions; manually choose Pressure, Guard, or a once-per-creature Assist each round; Withdraw is available |
| Duration | Cargo defense lasts at most three rounds; the territorial encounter lasts at most four |
| Consequences | Stamina and condition costs persist; cargo can be damaged; an unsuccessful encounter or withdrawal can cost food, cargo, or a day-long detour |
| Gathering | Camp foraging spends a day and daily meals; terrain, local depletion, carrying space, and an available Loamling affect the return |
| Gathering events | An authored root patch offers gathering with Loamling, gathering by hand, or leaving it |
| Hunting and fishing | No dedicated hunting, fishing, tracking, or pursuit system |
| Combat rewards | Passage or protected supplies; no repeatable XP, money, captured opponent, or meat reward |

The current foraging preview shows gross yield, how much can be packed, and the net provision change after meals. The implemented base yield depends on terrain and depletion; it does not yet apply a direct weather multiplier. Sources: [combat rules](../simulation/combat.lua), [expedition commands and forage preview](../simulation/expedition.lua), and [authored events](../content/events.lua).

## What to learn from the references

Automon's official description emphasizes automatic battles, building a varied creature party, individual abilities, upgrades, and randomized encounters. Its collection and combat progression make it a useful reference for immediately legible creature identities and preparation between fights. [Automon developer store page](https://store.steampowered.com/app/1822710/Automon/).

Astronarch explicitly emphasizes distinct hero skills, battlefield positioning, items that change a character's role, and choosing terrain that suits a party. It is the stronger reference for giving a small roster different builds and making the route part of combat strategy. [Astronarch developer store page](https://store.steampowered.com/app/1234940/Astronarch/).

The adaptations below are Trailomon proposals. They are not claims about either reference's exact targeting rules, timing, or item implementation.

| Reference | Apply here | Boundary |
| --- | --- | --- |
| Early Oregon Trail | Preparation, travel, supply pressure, dangerous crossings, increasing remoteness | The expedition remains the main source of decisions and success |
| Automon | Recognizable creature abilities and automatic fights shaped by the selected party | No capture-after-every-fight loop, duplicate merging, champion ladder, or elemental chart |
| Astronarch | Position matters; abilities combine; equipment can change a role; route selection tests the build | Begin with two positions and a tiny equipment experiment, not an inventory full of stat modifiers |

The resulting fantasy is preparing a capable traveling crew and seeing it act together. Combat skill includes knowing when a fight would spend effort needed at the next river.

## The proposed encounter loop

1. **Read the situation.** Show the opponent's behavior, the immediate objective, relevant ground or weather, and the peaceful options. The game pauses.
2. **Prepare the crew.** Choose one or two ready companions and place them at the approach or beside the wagon. Show what each will do automatically and its likely effort demand.
3. **Commit.** Begin a short automatic sequence. Each creature uses its species behavior; the player does not select an attack every exchange.
4. **Observe or withdraw.** Pause to inspect at any time. Withdrawal commits at the next unresolved exchange boundary with the displayed consequence. It is available before starting as well; fast reactions are never required to obtain the cheapest retreat.
5. **Account for the result.** Show what was protected or lost, effort spent, injuries, and the implications for the next travel day. Return to the stopped expedition state.

Use the current three- and four-round limits as initial exchange limits. Aim for roughly 15–30 seconds of readable presentation at normal speed, with pause, step, and faster playback. These are playtest targets, not final balance. A battle requires no mid-fight input to finish.

Keep one obvious decision per screen. The setup screen should not ask for creatures, positions, target scripts, individual stances, equipment crafting, and consumable timing all at once. For the first experiment, species behavior and position supply the strategy.

## Positions and automatic behavior

Use two physical positions visible beside the same wagon on the same stretch of road:

- **Approach:** the companion between the threat and the wagon. Direct rushes normally target this position.
- **Wagon:** the companion close enough to protect cargo or support the approach. It is less exposed, but explicitly described flanking or reaching actions can threaten it.

A single active companion occupies the approach. An inactive third companion remains with the traveler; it grants no invisible free combat bonus and cannot be swapped in during the first experiment. Readiness remains connected to condition and stamina.

Each species gets one ordinary action and one distinctive automatic ability. Ordinary action spends modest stamina. The ability has one clear trigger, a larger displayed cost, and initially one use per encounter. If the trigger never occurs, the ability is not spent. An exhausted creature uses a clearly weaker fallback; it never gains free full-strength protection by running out of stamina.

| Species | Ordinary action | Proposed automatic ability | Why its partner matters |
| --- | --- | --- | --- |
| Brindlehorn | Steady pressure from the approach; modest cover by the wagon | **Antler brace:** intercept the first direct rush toward cargo or its partner, reducing that hit | Creates a safe opening for a companion with a strong disruptive ability |
| Reedskipper | Quick pressure or a covering sweep | **Paddle sweep:** after the opponent commits to a direct rush, redirect it and reduce its pressure on the crew | Buys a safer exchange for a slower partner; its stored effort still matters at rivers |
| Loamling | Pressure through close, low movement | **Root hollow:** on diggable ground, prepare cover before the first incoming hit | Helps a fragile partner hold position; firm rock requires a weaker surface disruption instead |
| Bellmoth | Distracting passes with light pressure | **Dusk shimmer:** interrupt the first telegraphed heavy action | Supports an exposed defender; wind or heavy rain reduces the effect visibly |
| Cindercoil | Brief warning displays | **Warmth display:** spend stored effort on a strong burst of pressure after its partner holds off an attack | Rewards a defensive partner; warmth spent here cannot be assumed available without cost at camp |
| Slatewhorl | Slow pressure with reliable cover | **Stone shelter:** absorb part of the first threatened cargo hit while holding its position | Protects a more active companion; slow repositioning limits offensive speed |

These are candidate rules, not six abilities to accept without testing. Make triggers concrete in the setup preview, using the actual opponent and conditions. Avoid invisible percentage bonuses for a fashionable creature pairing. Combinations should work because one observable action creates an opportunity for another.

The current code groups assists into broad defensive and offensive effects. Distinct automatic abilities therefore require new simulation behavior; adding an auto-click option to the existing commands would not deliver this design.

## An example of a meaningful pairing

Moss and Ember meet scavengers after several wet travel days. Moss takes the approach; Ember stays by the wagon. The preview explains that Moss can intercept a rush and Ember can follow a successful defense with a warmth display.

The scavengers rush the load. Moss braces, reducing the hit; Ember's follow-up drives their resolve down. The encounter ends quickly, but both companions spend effort. If a cold camp lies ahead, sharing a little food with the scavengers might have been the better expedition decision.

On another trip, Moss arrives tired from hauling. Choosing it for the same combination is less attractive. A rested Reedskipper could take the approach, or the player could avoid the fight. The trip changes the value of the build before combat starts.

The result report should state the causes in ordinary language: "Moss braced the rush. Ember's display sent them back. Moss needs rest before another heavy task." Exact condition and stamina changes remain visible beside their usual icons.

## Equipment as a second experiment

Astronarch suggests a promising source of variation: a few objects that change how a companion contributes. Introduce these only after automatic abilities and positioning prove understandable.

Start with at most one equipped work item per active companion and three candidate items. The player equips them while stopped; swapping has no timer and cannot happen mid-battle. Carrying and purchase costs still compete with expedition supplies.

| Item concept | Travel use | Combat use | Tradeoff to test |
| --- | --- | --- | --- |
| Padded trace | Reduces the cost of a hard hauling task | Softens a direct hit while holding the approach | Added weight; does not protect against every threat |
| Release rope | Helps secure and recover crossing equipment | Limits a specific withdrawal loss by keeping supplies attached | Occupies capacity and an equipment slot; not a general damage boost |
| Dry wrap | Helps a vulnerable companion recover after rain | Preserves a weather-sensitive ability in a wet encounter | Modest load cost; no benefit in already favorable conditions |

Acquisition should fit the world: prepare at a depot, trade, repair a found object, or complete a relevant contract. Wild animals do not routinely drop manufactured equipment. Later unlocks can offer alternate work habits or items, with visible tradeoffs, rather than permanent attack inflation.

## Gathering and the hunting question

Expand gathering through decisions about place and effort: investigate signs, choose a capable companion, commit time, see a short automatic working scene, then account for the haul. This shares combat's presentation rhythm without treating roots as enemies with health bars.

A future gathering opportunity could show likely food, local abundance, required time, and whether the area appears occupied. Loamling helps find and dig food; Bellmoth helps locate signs; Reedskipper can recover floating supplies. Keep the current food, stamina, time, and capacity economy. Repeated harvests deplete the patch, and meals consumed during gathering remain part of the cost.

Automatic gathering should follow a deliberate player commitment. A creature must not silently leave the wagon, trigger a fight, or spend a day because the presentation clock advanced.

Hunting remains an open later option. It could make remote provisioning more varied, but needs a clear prey model, tracking decisions, carry limits, finite local opportunities, and a deliberate tonal choice. For the next experiment, use foraging and occasional contested resource sites. Do not reward attacking every animal or make companion recruitment depend on defeating it.

## Combat farther into the wilderness

Remoteness should change encounter context before it changes numerical difficulty. Near Fernwake, the player has supplies, warnings, and easy alternatives. Beyond the maintained road, fewer reports are current, refuge is farther away, and the same injury has a larger opportunity cost.

Introduce unfamiliar behavior through readable evidence: overturned stones, feeding marks, an animal guarding a ledge, a repeated warning call. Show the encounter's essential rules before commitment. A field journal can improve preparation without being required to understand the imminent threat.

Later encounters can protect a camp through a passing disturbance, recover an accessible food cache, or hold a crossing long enough to withdraw. These objectives can use the same automatic battle system. Vary terrain, threat behavior, and expedition circumstances before multiplying enemy types or adding boss gates.

Most travel days remain free of combat. A destination or route objective determines success. Reaching a farther horizon should not require clearing a linear ladder of fights.

## Interface and presentation

Keep the wagon and immediate terrain visible. Place companions in their two physical positions, connect the next visible threat to its target, and show condition and stamina with the established labeled symbols. Distinguish a temporary defensive effect from permanent condition; do not add a row of unexplained badges.

Use small, readable bodily actions: a brace, a sweep, a flash, a scrape, a retreat. Give the viewer enough time to see the trigger and its result. Keep flashes restrained and avoid giant damage numbers, rarity beams, arena backdrops, and effect clutter over the animals.

An optional log explains each exchange. Mouse and keyboard can select the crew, change positions, inspect abilities, start, pause, step, and withdraw. Verify this at the game's 1280 by 720 window size.

## The first implementation experiment

The implemented rules are now recorded in [COMBAT_RULES.md](COMBAT_RULES.md). The following brief preserves the experiment's original scope and acceptance criteria.

Replace manual action selection in the two existing scenarios with the proposed setup and automatic exchanges. Retain the six-species limit, two active companions, peaceful choices, encounter limits, visible resolve, and persistent expedition costs. Do not add equipment, new opponents, hunting, regions, or permanent skill trees in the same pass.

Resolve combat through a deterministic state machine separate from animation. At each exchange boundary, derive the threat and eligible triggers from saved state, resolve them in an explicit stable order, apply costs once, and record the result for presentation. Ability text must describe the order actually used. End the encounter before an already-repelled threat can deal another hit. Bound reaction triggers so abilities cannot recursively trigger themselves forever.

Save chosen positions, used abilities, pending intent, exchange number, and combat RNG state. Presentation speed, pause, frame rate, focus loss, or skipping an animation must not change the outcome. Existing saves in manual combat need a defined migration or completion path; they must not be silently interpreted as an automatic battle with missing setup.

Test the following before calling the experiment successful:

- A player can predict one useful pairing from descriptions and explain why it worked after watching.
- At least two materially different pairings work in each scenario; a defensive pair cannot stall indefinitely.
- Starting condition, fatigue, terrain, and order affect only the rules explicitly described.
- A favorable pairing is still sometimes worse for the expedition than paying, waiting, or taking a peaceful approach.
- Uninterrupted, paused, stepped, faster, and saved/resumed resolution produce identical simulation results for the same starting state and choices.
- One-creature crews, exhausted members, multiple triggers, withdrawal, and defeat all reach a valid result with costs applied once.
- A complete expedition without combat remains viable, and automatic battles occupy a small share of the total journey.

Use `tools/test.ps1` for simulation and persistence validation, `tools/build.ps1` for the release bundle, and an actual windowed playtest for readability and input. These checks belong to the future implementation; this document does not claim that automatic combat is already built or tested.
