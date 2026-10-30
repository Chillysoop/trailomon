# Trailomon Game Design

Version 0.1 | October 30, 2026 | Design baseline for a Defold prototype

Trailomon is a single-player wagon expedition game set in an original world of unusual wildlife. The player travels alone with a small crew of creature companions, carrying supplies and cargo between distant communities. Preparation, changing conditions, and the needs of the crew shape each journey. Creatures help overcome obstacles, find resources, and defend the wagon.

The central experience is a relaxed journey with consequential decisions. Travel unfolds automatically between meaningful stops. Players can pause whenever they wish; important choices always wait for them. Replayability comes from approaching familiar places with different companions, conditions, and plans.

The core direction is established. Creature names, world names, balance values, and duration targets below are initial design choices to test. The first playable scope in section 12 takes precedence over ideas marked for later development.

## 1 Product direction

| Item | Direction |
| --- | --- |
| Working title | Trailomon |
| Genre | Expedition survival and creature companionship |
| Player fantasy | A resourceful traveler whose unusual little crew makes difficult journeys possible |
| Core activity | Prepare, travel, observe, intervene, recover, arrive |
| Tone | Warm, curious, occasionally tense, with room for quiet and understated humor |
| Engine | Defold |
| Primary prototype platform | Windows desktop, mouse and keyboard, offline |
| Later distribution candidate | HTML5 for easy playtesting, after desktop behavior and persistence are validated |
| Prototype session target | 20–35 minutes for a complete trip; resumable at decisions |
| Longer-term journey target | 45–75 minutes, subject to prototype findings |

The player controls one traveler, one wagon, and a limited creature crew. Other people appear as traders, guides, clients, and fellow travelers; there is no human party to recruit or manage.

### Design pillars

1. **Let the road breathe.** Routine travel, meals, and overnight rest happen automatically. Interruptions earn the player's attention through a meaningful choice or discovery.
2. **Make preparation matter.** Food, time, money, equipment, and crew condition offer different ways to address trouble. No setup handles every situation equally well.
3. **Make creatures part of daily life.** A creature's body, behavior, habitat, and abilities matter during travel as well as combat.
4. **Build understandable consequences.** Weather, terrain, work, and previous decisions influence events. Players should usually understand why a situation arose and what could help.
5. **Preserve the value of another journey.** Knowledge and additional options carry forward while each expedition still requires preparation and judgment.

## 2 World and original identity

Travel connects inhabited regions with distinct climates, trades, and relationships with local wildlife. Communities rely on caravanners for deliveries, field observations, and occasional rescue work. The wagon is the player's mobile home and the visual center of the game.

Creatures belong to this world's ecology. People befriend them by understanding their habits, providing care, and sharing useful work. Companions remain physically present around the wagon and campsite. Recruitment uses trust and circumstances; creatures are not stored in capture devices.

Species concepts begin with a habitat, a physical adaptation, and a behavior. Combat uses those same adaptations. Avoid franchise-derived silhouettes, terminology, capture devices, move lists, or progression structures. Names and appearance concepts in this draft are provisional original concepts; final naming and art direction remain future production decisions.

The main goal is completing expeditions. A field journal records discoveries, while a small persistent roster provides attachment. There are no gyms, competitive leagues, universal elemental matchup chart, or mandatory collection completion objective in the current design.

## 3 Core gameplay loop

**Prepare at the depot → travel toward a landmark → respond to a meaningful situation → adjust or recover → reach the destination → keep discoveries and choose another trip.**

| Phase | Player decisions | Game behavior |
| --- | --- | --- |
| Prepare | Choose a crew and wagon, purchase supplies, review the contract and route forecast | Explain expected demands and show the cost of the loadout |
| Travel | Observe the road; optionally pause to change policies or stop | Advance discrete days, consume supplies, update condition and weather, and animate travel |
| Situation | Select an approach to an obstacle, opportunity, discovery, or encounter | Pause time; show relevant requirements, costs, risks, and known causes |
| Recovery | Rest, forage, repair, treat an injury, trade, or choose an easier path | Spend expedition time and resources through the same simulation |
| Landmark | Restock, obtain information, cross an obstacle, or select a branch | Give the stretch a clear ending and prepare the next one |
| Arrival or early ending | Review the trip and decide what to try next | Commit eligible discoveries, companions, records, and unlocks once |

### Travel rhythm

Travel uses a daily simulation inside a landmark-to-landmark journey. Display speed changes how quickly those days appear, never their economic effects. Provide pause, normal speed, and fast travel presentation. Opening a decision, crew panel, map, journal, or shop pauses time.

Pace, rations, and routine jobs persist until changed. Normal meals and sleeping are included in each day's net costs and recovery. A separate rest action represents an additional stationary day. Camping is an optional recovery decision and presentation moment, not a required daily checklist.

Major events pause travel. Minor observations, harmless creature behavior, and routine resource changes appear in the log without blocking progress. Start by testing quiet intervals of roughly two to four travel days between major incidental events. Landmarks have their own decisions and do not require an extra random event.

## 4 Expedition resources and condition

Keep the main travel display readable. Show the date and destination estimate, provisions, wagon condition, money, and crew condition. Repair materials and medicine remain visible in the supplies panel and when relevant to a choice.

| Resource or state | Function | Principal tradeoff |
| --- | --- | --- |
| Time and season | Determines arrival timing, weather, and route access | Recovery and investigation consume days that could have advanced the journey |
| Provisions | Feeds the traveler and crew | A larger crew offers more capabilities and requires more food |
| Coins | Purchases supplies, repairs, transport, and assistance | Spending now reduces flexibility at later stops |
| Wagon condition | Tracks wear and damage | Hurrying, rough terrain, and a heavy load increase strain |
| Carrying capacity | Limits supplies, trade goods, equipment, and cargo | Extra safety supplies occupy space needed for other opportunities |
| Repair materials | Restores wagon condition or supplies an obstacle solution | Repairs compete with provisions and cargo for capacity |
| Medicine | Supports recovery from injury | Treatment consumes supplies; rest may still be necessary |
| Traveler condition | Measures ability to continue | At zero, the expedition requires rescue |
| Creature condition and stamina | Separate injury from available effort | Working and fighting with the same companion can exhaust it |
| Contract cargo integrity | Measures success of the current delivery | Protecting cargo can cost time, money, or crew condition |

For the prototype, provisions are one resource. Water availability is a property of a route or campsite that affects recovery and risk; there is no separately managed water inventory. Detailed diets, nutrition, fuel, equipment durability, and individual morale meters are later candidates.

### Policies and recovery

| Policy | Options | Intended effect |
| --- | --- | --- |
| Pace | Easy, steady, hurried | Exchange daily progress for stamina use and wear |
| Rations | Sparse, normal, generous | Exchange food consumption for recovery and resilience |
| Routine creature duty | Travel work or rest | Use a suitable capability or preserve effort for later |

Initial scales are 0–100 for condition, stamina, wagon condition, and cargo integrity. The interface uses descriptive bands as well as numbers. Display relevant net daily changes so players can assess their plan.

A creature at zero stamina cannot perform strenuous work or combat actions. At zero condition it is incapacitated and travels under care. Default play has no permanent creature death. An injured creature remains a companion even when its capabilities are temporarily unavailable.

At a shop or camp, show how many travel days current provisions are expected to cover at the selected rations and crew size. Estimates update when the crew changes.

### No unlimited resource generation

Foraging spends one expedition day and companion stamina. Yield depends on habitat, weather, capability, and local abundance. Repeat visits deplete a site's yield; leaving and immediately re-entering does not reset it. A day of gathering also consumes the normal daily provisions. Show expected gross yield and net food change before confirming.

Repairs, treatment, and waiting use the same clock. Most resting benefits depend on having enough food and a suitable site. Helpful creatures improve these exchanges without creating unlimited food, water, warmth, or repair materials.

## 5 Creature companions

### Species and individuals

A species defines its silhouette, habitat, travel capability, combat expression, upkeep, and limitations. An individual adds a name, one temperament, condition, stamina, trust, and remembered experiences.

Temperaments should create recognizable preferences and useful tradeoffs. A curious creature can signal an interesting detour; the player decides whether to follow. A cautious creature may improve scouting while taking longer. Avoid frequent compulsory disobedience or random supply destruction as personality mechanics.

Keep species definitions separate from saved individual records. A new journey must not overwrite an existing companion's name or history.

### Prototype species roster

The six concepts below are the complete first-playable roster. Travel abilities and combat abilities share the same physical explanation. All six need a clear silhouette and simple idle, travel, effort, and distressed poses; they do not require elaborate animation sets.

| Species | Identity and habitat | Travel contribution | Combat contribution | Limitation | Starting budget cost |
| --- | --- | --- | --- | --- | --- |
| Brindlehorn | Shaggy grassland animal with broad, hollow antlers | Braces the wagon and improves hauling over difficult ground | Holds position and protects cargo | Heavy work consumes substantial stamina | 4 |
| Reedskipper | Broad-bodied marsh animal with webbed feet and a paddle tail | Pulls a light wagon, secures a crossing line, and retrieves floating supplies | Redirects an approaching threat or helps an ally disengage | Performs poorly during prolonged dry travel | 3 |
| Loamling | Compact burrower with digging forelimbs and a sensitive muzzle | Locates edible roots and tests soft ground | Disrupts footing and creates a defensive hollow | Hard rock limits its digging | 3 |
| Bellmoth | Large dusk moth whose wing scales reflect light | Reveals nearby trail markings and improves evening scouting | Distracts threats and conceals an ally's movement | Rain and strong winds reduce its effectiveness | 2 |
| Cindercoil | Small shelter-dwelling animal that releases stored warmth | Dries damp supplies and improves a cold rest stop | Drives a threat away with a brief heat display | Warmth requires food and recovery; it is not an unlimited heat source | 3 |
| Slatewhorl | Slow upland creature with overlapping stone-colored plates | Anchors ropes and stabilizes the wagon on a slope | Shields a companion or blocks access to cargo | Slow movement and high effort when repositioning | 3 |

Initially, Brindlehorn, Reedskipper, Loamling, and Bellmoth are available at the depot. Cindercoil and Slatewhorl can be befriended on the trail and retained after the journey. Wild opponents use species from this same roster; additional enemy species are outside prototype scope.

### Crew selection

Start an expedition with one or two companions within a seven-point starting budget. A full traveling crew has at most three companions. The third slot allows recruitment during a trip. The starting budget constrains departure choices; it is not an ongoing currency or a restriction on befriending a third companion.

Departure requires a companion capable of pulling the wagon: Brindlehorn or Reedskipper initially, with Slatewhorl available after recruitment. One ready draft companion must be assigned to haul on each travel day. Its species and the load affect progress and stamina use. A second draft companion allows rotation. If none can haul, movement stops and the player must rest, treat an injury, or request assistance. The preparation screen explains this requirement before departure.

All companions consume provisions. A rested companion can still be useful even when it is not assigned work. Two creatures with overlapping capabilities provide resilience but leave fewer slots for other kinds of help.

Routine duties persist. At an unusual challenge, the player chooses whether to commit a relevant creature. Show its current readiness and expected effort before confirmation. Equipment, waiting, payment, detours, or another capability should provide alternatives to a species-specific solution.

### Trust and recruitment

Use a short, authored sequence grounded in the creature's situation: notice a behavior, respond appropriately, and give the creature a reason to accompany the wagon. The prototype has one sequence for each discoverable species. An encounter can end peacefully without recruitment.

Before a creature joins, show the additional food demand and crew slot requirement. If the wagon is full, allow the player to help it without recruitment; its discovery remains recorded and its encounter can appear in a later expedition. Do not silently remove or release a current companion.

Trust persists as a simple relationship stage. It records becoming comfortable together and supports narrative recognition. It does not supply a large permanent stat multiplier. Prototype memories record concrete events, such as helping at a crossing, finishing a journey, or being rescued.

The prototype retains at most one individual of each species, keeping the home roster at six or fewer. A recruitment sequence is eligible only when that species is not already in the persistent roster or current crew. Multiple individuals per species and roster replacement decisions are deferred.

## 6 Obstacles and emergent events

Each event defines eligibility, visible context, options, costs, outcome rules, consequences, repetition limits, and journal entries. Eligibility checks geography and actual state. Explanatory text should reflect the factors used in resolution.

Separate three sources of change:

- **World conditions:** weather, recent rainfall, terrain, and local abundance.
- **Expedition condition:** load, supplies, equipment, injuries, fatigue, and policies.
- **Recorded history:** earlier choices, discoveries, help given, and unresolved situations.

Randomness varies a valid situation. It does not replace its cause. Rain can make mud and swell a downstream river; it should not independently produce contradictory descriptions of dry ground and flooding at the same location.

### River crossing example

At Willowford, show depth, current, recent weather, and the known condition of the crossing. Offer a ferry, waiting, or an assisted crossing. Availability depends on authored location rules; the prototype ferry remains available as a dependable paid alternative.

A swimmer can secure a line; an anchor creature can stabilize it. These contributions reduce specific risks and cost stamina. A tired crew, heavy load, or strong current still matters. Waiting changes the date and uses provisions, with an uncertain but explained weather outlook.

Outcomes include a clean crossing, a delay, wet supplies, wagon or cargo damage, and a companion injury. Most setbacks leave another decision to make. Severe consequences should follow a visible dangerous situation or prolonged neglect, rather than an unexplained lethal roll.

### Event pacing and fairness

Allow at most one major incidental event per day, with a starting cooldown of two travel days after resolution. Limit each major template to one appearance per trip unless it is an explicit follow-up. Quiet observations can occur during the cooldown. Known hazards and player-requested activities still apply normally.

Pause on a critical supply or condition threshold. Give an actionable warning before depletion when it can be forecast. Offer recoverable consequences and relief opportunities consistent with the location. Do not secretly erase the cost of a risky decision.

Store the selected event and its random state when it becomes pending. Reopening a menu or reloading a save must not reroll that situation.

### Example expedition story

Rain increases the risk at Willowford. The swimmer is tired from defending the wagon, so the player spends coins on the ferry. With less money for the next stop, the player chooses woodland forage and uses Loamling to find food. That detour exposes a Cindercoil shelter. Helping its inhabitant costs medicine, but the new companion later dries the delivery cargo. The journal preserves the actual sequence and the companions involved.

The individual encounters are authored; their consequences combine through shared resources and persistent state.

## 7 Battles

Battles are short, turn-based expedition encounters. Their purpose is to protect something, secure passage, or escape. They consume the same creature stamina and condition used on the road.

Select up to two ready companions from the crew for the encounter. Each selected companion receives one action per round. Show the threat's next intention before the player commits actions. Resolve a complete round, update persistent costs, and allow the next decision without a real-time timer.

| Command | Function |
| --- | --- |
| Pressure | Reduce a threat's willingness to continue through a species-appropriate action |
| Guard | Protect a selected companion or the wagon from the displayed threat |
| Assist | Use that species' distinctive ability, consuming more stamina and limited to once per creature per battle in the prototype |
| Withdraw | End the encounter through an explicit retreat choice with its known costs |

Withdrawal is a party decision made before round actions are committed. It cannot accidentally discard actions already selected. The interface states whether leaving costs cargo, provisions, or a detour.

The prototype has two scenarios: protect cargo for three rounds, and persuade a territorial creature to retreat within four rounds. The latter uses a visible resolve meter. At the round limit, resolve the stated fallback, such as a detour or cargo loss; encounters cannot continue indefinitely.

Victory preserves expedition resources or provides access to a route or opportunity. There is no repeatable battle XP or money farming. Injuries and fatigue persist. De-escalation, payment, distraction, and avoiding an encounter remain valid options. A player can complete the prototype without fighting, while fixed demonstration seeds make both scenarios easy to test.

## 8 Replayability

Keep the region recognizable. Change the circumstances and the crew. Players should learn the meaning of a place and then discover another way to travel through it.

| Replay source | First playable | Later expansion |
| --- | --- | --- |
| Crew combinations | Four starting species, two discoverable species, persistent individuals | Additional species, relationships, and specialist teams |
| Route choices | One route with two branch decisions | More routes and starting regions |
| Conditions | Seeded weather, recent rain, varying eligible events | Multiple seasons, migrations, and regional situations |
| Preparation | Standard wagon and an unlockable covered variant | More equipment with clear tradeoffs |
| Knowledge | Useful journal entries and route familiarity | Connected ecological mysteries and regional guidebooks |
| Goals | One delivery contract with graded outcomes | Survey, rescue, relocation, and trade expeditions |
| Personal challenge | Review outcomes and replay a seed | Optional restrictions and shareable expedition codes |

A seed plus the same decisions and game data version should reproduce the same simulation. The seed does not lock the player into an identical outcome when they make different choices.

The first trip must be enjoyable with the initial options. Unlocks support experimentation; they do not compensate for an incomplete starting toolset.

## 9 Meta progression

The persistent profile represents a modest home depot: companions, field knowledge, expedition journals, and unlocked preparation options. A management game around the depot is outside the initial scope.

| Persists between expeditions | Resets or is selected anew |
| --- | --- |
| Named companions, trust, and remembered experiences | Active traveling crew and its departure loadout |
| Species and habitat observations | Current route conditions and event state |
| Unlocked wagon configurations | Coins, consumable supplies, and cargo |
| Completed journey records | Date, location, contract progress, and local forage depletion |
| Cosmetic recognition and future narrative relationships | Temporary injuries and exhaustion after the offscreen recovery period |

Recovery between trips is automatic in the prototype, with no real-time wait or fee. This protects the relaxed tone and prevents one unsuccessful journey from making the next departure untenable.

### Prototype persistence

Persist the six-species discovery journal, individual companions, up to ten expedition summaries, and one wagon unlock. Begin with the standard wagon. Record a substantive river observation by inspecting Willowford and completing a crossing. After that expedition reaches an ending, unlock the covered wagon.

The covered wagon reduces losses from wet weather but has lower carrying capacity. It is an alternate configuration, not an unconditional improvement. Both configurations must remain viable after the unlock.

Discovery and recruited companions can persist after arrival, early return, or rescue. Delivery recognition depends on the actual result. A unique expedition ID makes completion and rewards idempotent: loading a result screen cannot grant them twice. Repeating the same observation yields no additional unlock currency.

Longer-term progression can add routes, wagon recipes, a few learned specialties, and relationships with communities. Unbounded stat growth, mandatory failure grinding, real-time companion recovery, and daily login rewards are outside the intended progression model.

## 10 Endings and consequences

| Ending | Trigger | What the player receives |
| --- | --- | --- |
| Successful delivery | Reach the destination before closure with usable cargo | Delivery result, journal, companion memories, discoveries, and eligible unlocks |
| Damaged or late arrival | Reach the destination with ruined cargo, or miss the preferred delivery date before route closure | Reduced delivery recognition and a complete account of the trip |
| Early return | Choose return at a settlement or call for assistance while stopped | Retained discoveries and companions; incomplete delivery |
| Rescue | Traveler condition reaches zero, the wagon is disabled without a feasible recovery, or the route closes | Retained discoveries and companions; failed delivery and a concise explanation |

The first playable has a preferred delivery date and a later, forecast route closure. These are game-calendar constraints. There are no real-time countdowns on decisions. Calling for assistance is always available from a stopped state so a resource shortage cannot trap the player in an unwinnable interface loop.

A result screen explains what happened through three or four significant moments, final crew condition, cargo outcome, route taken, and newly available options. It should help the player form a plan for the next trip.

## 11 Presentation and usability

Use a side-view 2D travel scene with the wagon and all active companions visible. Distinct silhouettes, readable poses, changing terrain, weather, and a restrained soundtrack carry the atmosphere. Landmarks receive larger illustrated views and a brief arrival moment.

Prototype art can be simple original placeholders. Prioritize a readable travel screen and event choices before detailed pixel animation. Target a 1280 by 720 layout that remains usable at common desktop sizes. Text readability takes precedence over a tiny retro font.

Provide seven functional views: depot and preparation, travel, map, crew and supplies, event or landmark, battle, and journal or expedition result. Views may share panels and a single GUI scene rather than requiring separate engine scenes.

Use mouse interaction with keyboard navigation, Space to pause travel, and Escape to close a noncritical panel. No timed responses or reflex requirements. Costs and outcomes use text and icons as well as color. Include independent sound controls, text speed or instant text, and an option to reduce motion. Optional flavor inspection must not secretly advance expedition time.

### Creature art and Sprite Fusion workflow

Use Sprite Fusion for original creature sprite studies and subsequent production variants. Establish the palette, outline treatment, scale beside the wagon, and readable silhouette with one creature before expanding the roster. The initial [Brindlehorn studies](../assets/concepts/README.md) test russet and cream fur, sage harnesses, and broad antlers. They are concept alternatives; their varying dimensions and camera angles still need production cleanup.

The intended sequence is to generate a concept, edit the selected asset into the required pose, use that asset as a style reference for the next creature, then animate approved poses. Keep source asset IDs and prompts with each study. Validate actual output dimensions, transparency, pivot alignment, and frame consistency before importing images into Defold atlases. Favor a small idle loop and a readable walk cycle over many actions.

Eight-direction generation is available if a later camera design needs it. The first playable uses a side view, so additional directions are outside its art budget. Normal maps are optional for a later lighting experiment; the initial presentation uses ordinary sprite lighting. Sprite Fusion requests belong in development tooling, with credentials kept outside project files and builds. See the [API reference](https://www.spritefusion.com/docs/pixel-art-generator/api/api-reference) for generation, editing, style references, directional sets, animation, and normal maps.

## 12 First playable scope

The first playable proves a complete, replayable expedition with connected creature and survival decisions. It is not the full game's content foundation multiplied across many regions.

### Scenario and route

Deliver a crate of living orchard cuttings from Fernwake Depot to Lantern Reach before cold weather closes the upland road. Wet exposure, impacts, and neglect can damage the crate. Protecting it must compete with protecting the crew and preserving supplies.

The route has exactly six landmarks, including the starting and ending settlements:

1. **Fernwake Depot:** choose the crew, wagon, and supplies; review the contract.
2. **Split Oak:** choose meadow or woodland travel to Mossbell.
3. **Mossbell Outpost:** the only intermediate shop; rest, resupply, and obtain useful route information.
4. **Willowford:** inspect and cross the river; use the ferry, wait, or attempt assistance.
5. **Cairn Gate:** choose a shorter exposed ridge or a longer sheltered gorge.
6. **Lantern Reach:** resolve the delivery and end the expedition.

Both options at each branch rejoin the same next landmark. Branches change distance, exposure, forage, and eligible encounters. The river is a separate obstacle decision, not a third branch or additional landmark.

Initial tuning target: 18–22 travel days before stops, preferred delivery by day 26, and road closure at the start of day 32. Waiting and side activities add days. Weather provides variation within one departure season. These values must be adjusted together after complete-route playtests.

### Content and feature budget

| Area | Required scope |
| --- | --- |
| Route | Six landmarks and two branch decisions |
| Creatures | Six species total; four initially selectable and two recruitable |
| Crew | One or two companions at departure; maximum three on the road |
| Wagon | Two configurations total; standard available initially, covered unlocked through the first river study |
| Contract | One fragile delivery with successful, damaged, early-return, and rescue outcomes |
| Supplies | Provisions, medicine, repair materials, coins, and contract cargo; one capacity limit |
| Policies | Three paces, three ration settings, and persistent work or rest duties |
| Weather | Clear, rain, and cold conditions with recent-rain accumulation |
| Major obstacle | One river system using conditions and available assistance |
| Trail content | Eighteen authored event definitions, listed below; landmark interactions are counted separately |
| Battles | Two scenarios, using the six existing species and a shared command system |
| Provisioning | One foraging system; no separate hunting or fishing minigame |
| Progression | Discovery journal, named companions and memories, ten saved trip summaries, one wagon unlock |
| Saving | One active expedition plus persistent profile; pause, quit, and resume at stable decisions |
| Presentation | Original placeholder art, simple travel animation, basic feedback sounds, readable GUI |
| Debugging | Seed entry, state inspection, event forcing, and quick simulation controls for developers |
| Delivery | A Windows build that runs without the editor |

### Eighteen event definitions

| Category | Definitions | Design purpose |
| --- | --- | --- |
| Eight choice events | Mudbound wheel; strained axle; damp provisions; cold campsite; fallen tree; tempting root patch; traveler seeking help; disputed shortcut | Exercise time, supplies, information, condition, and alternate approaches |
| Four ambient events | Quiet grazing; shared shade; distant calls; companion play | Give the journey character without a blocking choice |
| Four discovery events | Cindercoil shelter; Cindercoil follow-up; Slatewhorl tracks; Slatewhorl follow-up | Support the two recruitment sequences and useful ecological knowledge |
| Two encounter events | Scavengers at the wagon; territorial creature at a narrow path | Offer peaceful responses or enter one of the battle scenarios |

Only eligible events appear. Every normal trip need not contain all definitions, all recruitment sequences, or a battle. Use fixed test seeds and a debug selector to exercise rare content without forcing it into every player's journey.

### Explicit exclusions

The prototype excludes free-roaming movement, multiple regions or seasons, breeding, evolution trees, elemental matchups, large move lists, battle XP, procedural world generation, base construction, a crafting tree, individual nutrition, human party management, permanent creature death, multiplayer, online accounts, cloud saves, daily challenges, mobile controls, commercial monetization, voice acting, and a large narrative campaign.

HTML5 is a later portability check, not a required second prototype delivery. Additional content must replace something in this scope or wait until the first playable is evaluated.

## 13 Defold implementation plan

Use Defold's 2D sprites, atlases, GUI components, Lua modules, and message passing. Keep the expedition rules in Lua modules that can run without presentation components. Defold provides the documented building blocks for [Lua modules](https://defold.com/manuals/modules/), [GUI scenes](https://defold.com/manuals/gui/), [atlases](https://defold.com/manuals/atlas/), and [message passing](https://defold.com/manuals/message-passing/).

Choose and record a stable Defold editor and engine version when implementation begins. This document does not depend on a particular release number.

### Proposed structure

    game.project
    main/
        main.collection
        app.script
    simulation/
        expedition.lua
        travel.lua
        weather.lua
        resources.lua
        creatures.lua
        events.lua
        combat.lua
        progression.lua
        rng.lua
    content/
        route.lua
        species.lua
        events.lua
        encounters.lua
        wagons.lua
    ui/
        game.gui
        game.gui_script
    presentation/
        travel.collection
        travel.script
    services/
        save.lua
    assets/
        atlases/
        fonts/
        audio/
    tests/
    docs/
        GAME_DESIGN.md

This is a planned layout; the design milestone does not require creating placeholder engine files.

### State and timing

Use explicit modes: preparation, traveling, stopped, event, landmark, combat, and result. One controller owns transitions and one expedition state owns simulation data. GUI actions submit commands, and presentation observes the resulting state. Avoid parallel timers or GUI scripts independently changing supplies.

A daily step updates morning weather, checks warnings, consumes provisions, applies work and recovery, advances progress where appropriate, updates condition, and selects eligible incidents in a documented fixed order. Update recent rainfall before resolving that day's river conditions. Stops and actions that consume a day call the same time system with movement disabled. UI display frames never directly consume resources.

During travel, an accumulator determines when to request a day step. On a pause or mode change, discard unused accumulated travel time so closing a panel cannot unexpectedly advance several days. An event suspends the remaining travel sequence until it is resolved. Long actions check warnings and terminal conditions after each day rather than skipping past them.

Treat content tables as immutable definitions and create new tables for each expedition and creature instance. Defold caches required modules, so mutable run state must not remain accidentally shared across restarts. Use small messages for commands and state-change notifications; query larger snapshots through the model rather than sending the entire journal in a message.

### Data and deterministic randomness

Content definitions use stable IDs. Event records contain prerequisites, cooldown tags, presentation text, choices, costs, outcome effects, and journal templates. Begin with a small set of Lua helpers; do not build a general-purpose event language or visual editor for this prototype.

Use an explicitly stored deterministic random generator with separate streams for weather, event selection, and combat. Keep cosmetic randomness separate. Save stream state and pending choices. The same seed, commands, and data version must produce matching results across save/resume and display speeds.

### Persistence

Use Defold's application save path and table serialization through [sys.get_save_file, sys.save, and sys.load](https://defold.com/manuals/file-access/). Protect loads against malformed data and validate a schema version before restoring state.

The save contains the active expedition, profile, unique expedition ID, schema and content versions, random states, pending event or round, and journal. Save a single consistent snapshot so profile rewards and expedition completion cannot disagree. Maintain a last-known-good backup and expose a clear recovery option if loading fails.

Autosave after completed days and accepted decisions, on entering an event, and at battle round boundaries. A manual save request during animation finishes at the next stable boundary. Pause the animation and show when saving has completed. Resume at a decision boundary with all pending context intact.

Use only supported serializable data in the snapshot. Validate the eventual journal and roster size against the engine's save limits; bound prototype history to ten summaries. Later HTML5 support requires a separate check of browser persistence and platform behavior using the [official HTML5 manual](https://defold.com/manuals/html5/).

### Implementation milestones

| Milestone | Deliverable | Exit condition |
| --- | --- | --- |
| M1 Travel foundation | Defold project, travel view, pause/speed controls, fixed route, daily resource simulation, and restart | A placeholder crew can reach an ending; display speed does not change the result |
| M2 Expedition decisions | Branches, shop, river, weather, recovery, warning states, and all endings | Preparation and route decisions affect survival; the player can recover or end a bad run without becoming stuck |
| M3 Creature journey | Six species, routine duties, eighteen trail events, recruitment, and both battles | Creatures change available approaches; fatigue and injuries connect travel and combat |
| M4 Persistent return | Save/resume, named roster, journal, one wagon unlock, and expedition results | A second trip uses retained knowledge and options; reloading never duplicates rewards or rerolls a pending event |
| M5 First playable delivery | Readable art and sound, controls, balance pass, regression checks, and a packaged Windows build | A new player can complete and replay the journey without developer intervention |

Each milestone remains playable. Dates and effort estimates are set after M1 establishes the actual implementation pace.

## 14 Verification and playtest criteria

### Functional acceptance

- Start, complete, return early from, and fail an expedition through explicit end states.
- Exercise both branches, both wagon configurations, all six creatures, both recruitment sequences, and both battle scenarios using normal choices or controlled seeds.
- Stop time in all decision and inspection views. Changing display speed must not change simulation outcomes.
- Preserve state across quit and resume, including a pending event, a battle boundary, and a result awaiting acknowledgement.
- Apply completion rewards once. Restarting a run must not retain resources or damage from the previous active state.
- Prevent negative inventories, over-capacity purchases, duplicate recruitment, and selection of unavailable actions.
- Demonstrate an arrival without combat and an arrival without either recruitable species.
- End a disabled journey through recovery, return, or rescue; never leave an unusable Continue button as the only action.
- Run the Windows bundle without the Defold editor installed.

### Meaningful simulation checks

Test resource accounting, prerequisite validation, seeded repeatability, state isolation, terminal transitions, and save/resume equivalence. Include a short route traversal that joins a creature, crosses the river, resolves a battle, and finishes. Compare uninterrupted execution with a save/resume at the same decision boundary.

Use a batch of documented seeds with at least two reference strategies to inspect event frequency, recovery access, and failure causes. These simulations identify balance problems; they do not establish whether the game feels relaxed or enjoyable.

### Player experience targets

Use a small formative test with roughly five players new to the build. Treat these as revision criteria, not statistical proof:

| Question | Initial target |
| --- | --- |
| Do players understand the objective and supplies? | Most can explain the contract and food estimate after preparation |
| Do creatures matter beyond battle? | Each tested crew produces at least two consequential noncombat uses during a trip |
| Are consequences understandable? | Players can connect a major setback to at least one visible factor or earlier decision |
| Does travel feel relaxed? | Players can identify enjoyable quiet stretches and do not describe routine care as repetitive chores |
| Does the journey support recovery? | A meaningful setback can lead to a changed plan and a viable outcome |
| Is there a reason to replay? | Most can name a specific crew, route, or preparation change they want to try before being prompted about unlocks |
| Is the scope a complete playable experience? | At least one new player reaches an ending and starts another trip without developer assistance |

Revise the journey before expanding it if players only want to repeat for unlock rewards, if one crew makes all other preparations irrelevant, or if frequent interruptions dominate the road.

## 15 Decisions to revisit after the prototype

The prototype supplies defaults for these questions so implementation can proceed. Revisit them with playtest evidence:

- Whether a seven-point starting budget and three-creature maximum create enough variety.
- Whether the covered wagon is a meaningful alternative and whether its unlock occurs at the right time.
- Whether forage, recovery, and combat consume enough time to matter without creating a scarcity spiral.
- Whether players want longer trips, more routes, or greater variation within the existing route first.
- Whether one individual temperament is sufficient, and which remembered experiences deserve mechanical effects.
- Whether the next contract should emphasize discovery, rescue, or trade.
- Whether HTML5 distribution is worth prioritizing after the Windows prototype.

## 16 Design references

The early Oregon Trail games are the primary structural references. Their sequels supply selected refinements, and creature games supply lessons about companions, readability, and discovery. The adaptations below are design proposals, not claims that the reference games implement Trailomon's systems. When influences conflict, preserve the expedition's relaxed rhythm and meaningful resource decisions.

### Expedition structure: highest priority

- [Surviving 1975 Oregon Trail code](https://github.com/fortran-gaming/oregon-trail-1975/blob/main/oregon-trail-1975.bas): a compact resource economy with competing uses for time and supplies.
- [Philip Bouchard on the 1985 design framework](https://www.philipbouchard.com/oregon-trail/imagining-design.html): daily simulation inside a landmark-based journey.
- [Philip Bouchard on the travel screen](https://www.philipbouchard.com/oregon-trail/travel-screen.html): automatic travel with meaningful interruptions.
- [Philip Bouchard on river crossings](https://www.philipbouchard.com/oregon-trail/crossing-rivers.html): conditions, choices, and graduated consequences.
- [Oregon Trail II official strategy guide](https://archive.org/details/Oregon_Trail_II_Guide): interactions between capabilities, equipment, and environmental conditions.
- [Oregon Trail 3rd Edition manual](https://archive.org/details/oregon_trail_3rd_edition_manual): companions with different skills and personalities.
- [Oregon Trail 4th Edition manual archive](https://www.old-games.ru/game/download/7738.html): preparation packages and companion assistance.
- [Oregon Trail 5th Edition manual](https://paperzz.com/doc/9206938/oregon-trail%C2%AE-5th-edition--adventures-along-the-oregon-tr...): journey recording and varied ways to obtain supplies.

### Creature identity and discovery: supporting references

Include a small selection of creature games, each with a specific design question. These are references for studying systems and presentation, not sources of characters, names, sprite shapes, interfaces, or setting details.

| Reference | What to study | Trailomon application | Scope boundary |
| --- | --- | --- | --- |
| **Pokémon Red / Blue** | How compact sprites, memorable creature identities, and a limited traveling team make individual companions easy to recognize | Give every prototype species a distinct silhouette, a clear expedition role, and a name players remember; make choosing the starting crew consequential | Keep the expedition as the central activity. Gym progression, a large elemental chart, collection quotas, and repeated battles for levels are excluded |
| **Pokémon Mystery Dungeon: Explorers of Sky** | A persistent exploration team, preparation at a home base, food and move resources during outings, and consequences for failed expeditions | Treat a journey as an outing with a chosen crew and a shared supply budget; let returning companions accumulate memories and support another attempt | Use Trailomon's forgiving recovery rules. Dungeon grids, per-step input, extensive item management, and permanent stat grinding are outside the prototype |
| **New Pokémon Snap** | Returning to familiar courses to discover changed encounters and behaviors; day/night and research-level variations | Give familiar trail segments different eligible wildlife scenes under rain, cold, crew composition, and prior discoveries. Journal knowledge should suggest something specific to investigate next time | Implement a few authored conditions and follow-ups. Photography, timed reactions, research-level grinding, and a full day/night simulation are excluded |
| **Monster Sanctuary** | Creatures with useful exploration abilities as well as combat roles, and complementary team composition | Make the same physical trait useful in both contexts: Brindlehorn braces a wagon and guards cargo; Bellmoth scouts the trail and distracts a threat | Replace mandatory ability gates with alternate costs and approaches. A missing species must not block the only route; large skill trees and deep combo combat are excluded |

Primary reference material: [Pokémon Red official overview](https://www.nintendo.com/en-gb/Games/Game-Boy/Pokemon-Red-Version-266109.html), [Explorers of Sky instruction booklet](https://www.nintendo.com/eu/media/downloads/games_8/emanuals/nintendo_ds_21/Manual_NintendoDS_PokemonMysteryDungeonExplorersOfSky_EN.pdf), [New Pokémon Snap official tips](https://www.pokemon.com/uk/features/top-tips-to-begin-your-new-pokemon-snap-journey), and [Monster Sanctuary developer overview](https://monster-sanctuary.com/).

Mystery Dungeon is the most useful creature-side structural comparison because it connects preparation, companions, limited expedition resources, and returning home. Snap is especially useful for repeat visits and a world that feels alive. Monster Sanctuary tests whether every creature deserves a place outside battle. Early Pokémon is the reference for immediate recognition and affection for a small team.

For the prototype, test those lessons with three concrete situations: the same river approached by two different crews, a discovery encounter whose eligibility changes with conditions or prior help, and a returning companion whose journal records a shared incident. These tests fit the existing content budget. A larger reference list is unnecessary until a specific unresolved design problem calls for it.
