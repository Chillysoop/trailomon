# Trailomon — integrated game plan

**November 4, 2026.** Defold + Lua. Offline Windows. One complete, readable expedition before expanding the world. This replaces the earlier plan, preserved in [the archive](archive/PLAN-2026-11-04.md).

**The game:** a creature-collecting wagon expedition in which the team you befriend, train and equip determines how you survive increasingly dangerous country. Astronarch-style automatic battles are a central source of tension. The Oregon Trail journey gives those battles a purpose: protecting a delivery, managing a battered wagon, choosing how far to push, and deciding when to seek care. The map and the creatures lead the interface.

This is a development plan, not a claim that proposed systems already exist. [The integration blueprint](INTEGRATION_BLUEPRINT.md) defines system boundaries, visuals and save behavior. [The roadmap](ROADMAP.md) orders playable deliveries. These documents supersede conflicting older design proposals; historical saves still need their original rules.

## 1. Established direction

- One traveler, one wagon, up to four active companions. An uncapped collection of individuals, including duplicates, lives at Wayhome Commons.
- Original creatures grounded in habitats, bodies and behavior. Individual abilities replace a universal type chart or fixed class system. Combat specialists and ordinary wildlife do not need mandatory travel utility.
- The eventual index contains **at least 300 distinct species**. Six are playable; 24 briefs exist. Empty index slots and recolors do not count as species.
- Combat follows Astronarch's preparation, formation, independent attack clocks, repeating skills and interacting items. The wagon is an additional defendable target. Automon informs collecting appeal rather than the resolver.
- Battle leveling, heal/revive stops, reserve exchanges, species-specific equipment capacity, individual sheets, item discovery and an implemented-item catalogue are directly requested.
- A more robust wagon/cargo/repair system is requested; its exact component and packing model is proposed below.
- Visual clarity is a release requirement: minimal routine text, shared original icons, consistent colors, contextual explanations and meaningful movement. Existing creature assets remain until the later owner-led overhaul.
- PC/local review is sufficient. Hosted phone publication is no longer a default requirement.

## 2. The connected loop

**Meet → collect → choose four → equip → choose a route → defend the wagon → earn growth and discoveries → repair, heal or exchange → push farther → return with new possibilities.**

| Decision | Immediate effect | Later consequence | Visible connection |
| --- | --- | --- | --- |
| Befriend a creature | New individual joins party or Commons | New formation, skill or equipment capacity | Encounter → portrait → sheet |
| Equip for combat or travel within available slots | Changes attacks, skills or road assistance | Changes the threat/route the team can handle | Sheet → forecast → result |
| Take a dangerous branch | More serious encounter/discovery opportunity | XP and gear options versus injuries and damage | Map → battle → receipt |
| Put a protector in a raider's zone | Redirects pressure away from the wagon | Preserves delivery prospects; protector may need care | Target line → hit → care preview |
| Exchange an injured fighter | New team composition | Less treatment spending; different hauling/meals | Stop → party → next-leg forecast |
| Carry more repair supplies | Less load for food/finds | More freedom to take rough routes | Wagon → route outlook |

**Feature admission rule:** improve at least two parts of this loop, give the feature one obvious visual home, and explain any new persistent meter. This applies to systems, not a requirement that every species have several utility jobs.

## 3. Five pillars

1. **Preparation becomes visible action.** The player follows targeting, skills, protection and the reason a build worked.
2. **Battles matter afterward.** Injuries, growth, gear and wagon consequences immediately affect the journey.
3. **Collect possibilities; remember individuals.** Identity, origin, level and history belong to individuals, including duplicates.
4. **Push farther from help.** Early stops support and teach; later stretches demand preparation. Calm means time to decide, not an absence of danger.
5. **Read the world before a ledger.** Geography, creatures, targets and visible damage explain decisions; detailed accounting is available on inspection.

## 4. Shipped baseline and gaps

Playable baseline: **PR #53 / 46ac095**. The installed desktop shortcut follows the latest successful local player build.

| Area | Shipped | Needed connection |
| --- | --- | --- |
| Journey | Six stops, two forks, weather, food, deadline, moving map wagon | Stable arrival; visible threats/services; fewer repeated confirmations |
| Collecting | Four active, uncapped individuals, duplicates, origins, waybeds | Reserve exchange at stops; active/reserve sheets |
| Combat | Six kits; independent attacks/Focus; front/rear lanes; wagon defense; two road encounters and practice | Two zones, target previews, encounter composition and rewards |
| Growth | Habits, trust, observations and memories | Individual battle XP/levels and readable stat effects |
| Equipment | Three work items, one slot, run inventory/weight | Species-specific sockets; catalogue, discovery and interactions |
| Recovery | Camp, medicine, repairs and lasting injuries | Named heal/revive stops; coherent quotes; reserve access |
| Wagon/cargo | Wagon %, cargo %, load/capacity; open/covered variants | Better explanation; evaluate components and protected loads |
| Interface | Main map/party updated; older secondary menus remain | Shared sheets, help, targeting and consequence presentation |

An **unreleased simulation experiment** exists on `codex/expedition-rpg` (`874cb5d`). It is not player-ready: the old UI does not support its new positions, new-system tests and balance are incomplete, and no build/PR was shipped. Its tentative XP, prices and early-enemy tuning are not commitments. Reuse reviewed pieces in roadmap order, not as one unchecked merge.

### Fresh playthrough evidence

On November 4, a developer-driven Discovery run of the actual release renderer used seed 1848 and a solo Brindlehorn. It delivered on day 26 with 80 cargo, zero food and four companions. It contained **one battle**, lost by crew knockout, followed by field recovery. No encounters/resources were forced. [Recorded evidence and limits](../reviews/evidence/integration-2/baseline.json).

Observed gaps: opening an encounter resizes the map; care is spread across menus; departure/outcomes often require another Travel click; battles grant no individual growth; one early fight does not sustain combat tension. This is one seeded developer playthrough, not a population balance result or blind human fun score. Updated expert/new-player full runs remain required.

## 5. System direction

### Collection, powers and growth

Each individual retains ID, name, species, origin, total XP, derived level and memories. The traveling instance also has health, energy, duty and equipment. A duplicate is a new individual, not a species-wide stat upgrade.

First slice: one repeating active skill, one innate passive, and a field action when ecology supports one. Show these separately. Gear modifies interactions; no second skill tree is necessary. A combat specialist may lack a field action.

Battle XP gives modest visible growth. Leveling must not heal, erase damage or lower food needs. Reward eligible participants once per qualifying victory, including creatures knocked out during that fight; exclude those unready at the start. No last-hit competition or unlimited practice XP. Preserve earned progress after an unsuccessful delivery. Tune the curve/cap from full runs; avoid mandatory grind and automatic enemy scaling that cancels growth.

### Combat and encounters

Two zones per side, each a 2×2 formation area; at most four active companions. Ordinary target priority: **opposing zone → front before rear → nearest eligible position → stable tie-break**. Named skills can override it explicitly. Raiders threaten the wagon through an unguarded zone; that is Trailomon's addition, not an exact Astronarch rule.

Show target lines, incoming threats and click-to-place slots before Start. Attacks and Focus remain separate clocks; skills repeat automatically. Pause for inspection is free. Results show consequences for the actual traveling party and return to the same map location.

Author threats by stretch/habitat with quieter opportunities between them. Initial test target: **four to six combat opportunities per expedition**, some avoidable. This is a tuning hypothesis, not a forced battle quota or measured playtime percentage. A solo opening must be fair with visible information. Later fights should test different preparations. Fixed world difficulty and optional dangerous routes preserve the value of training.

### Care and reserve exchanges

Marked stops use the Wayhome roadkeeper network to heal/revive, exchange reserves and repack. Price them to leave room for exploration; exact costs belong to balancing. Camp/medicine remain resource-dependent fallback care in remote country.

Exchange only at a stop, outside combat. Preserve outgoing injuries so swapping twice cannot heal. Keep at least one hauler; preview changes to meals/hauling. Outgoing gear stays in the wagon. Reserves neither fight nor eat in the background. Stop recovery and end-of-trip home recovery are explicit transactions.

### Equipment and discovery

One inventory supplies both road and combat. Each item has one ID, source, weight, slot compatibility and implemented effects. No separate battle bag.

First target: the three existing tools plus roughly nine to twelve distinct additions. The catalogue includes **every implemented item**, including consumables, with discovery, source clue, ownership/location, compatibility and exact effect. It does not imply hundreds of finished items. Knowledge persists; first-slice equipment is packed per expedition, matching the existing economy. Reconsider permanent gear only if repeat preparation proves tedious.

Start with three sockets per species: two combat + one utility for combat-oriented bodies; one combat + two utility for hauling/support bodies. Anatomy determines layouts without creating a universal class chart. Old gear goes into a compatible utility socket. Unavailable sockets and available-but-empty sockets look different.

### Wagon/cargo/repair — two open proposals

**G1: three functional components.** Running gear affects mobility/haul strain; frame affects structural safety; cover affects exposure. Show them on the wagon and derive one roadworthiness summary. Select a damaged part to compare a field patch and service repair. Replace the single opaque health abstraction for new runs, rather than adding three permanent HUD bars to it. Keep an escape from every breakdown.

**G2: protected cargo positions.** Retain weight/capacity as the limit, but show two protected positions and an exposed rack. Choose which meaningful loads get shelter: delivery crates, food or valuable finds. Cover, terrain and creature help change that choice. No Tetris grid, item rotation, per-apple durability or repeated stack management.

Only these new refinements need votes on [integration-2](../reviews/integration-2.html). Combat, growth, care, sheets and equipment already have direct authorization. If either proposal is rejected, keep its current underlying resource and improve the explanation; do not block the rest of the loop.

## 6. Visual direction

- **Journey:** the actual map dominates. Wagon, destination, forks, threats and next care stop are readable without opening menus. Arrival never teleports the wagon when a panel opens.
- **Battle:** shared field, legible zones, opposing formations, target-local feedback, overhead HP/Focus/attack meters and visible wagon danger. Inspection replaces a permanent stat wall.
- **Sheet:** a recognizable creature with name/level, health/energy, active/passive, sockets and origin/history. Same design for traveling and stored individuals.
- **Wagon:** locate cargo and damage on the object. Main-screen warnings are short and actionable. Distinguish structure, load and delivery quality.
- **Help:** underlined keywords provide short explanations on hover, keyboard focus or click. Essential prices, danger and requirements stay visible. A tooltip answers what it means, what changes it and why it matters here.
- **Color/icons:** use the semantic catalog. Leaf food/cargo, brass time/energy, rose health/care, river shield/rest/water, violet skills/records, stone wagon/load/repairs, clay threat. Shape, words and signed values work without color.

[The visual acceptance contract](INTEGRATION_BLUEPRINT.md#visual-acceptance-contract) specifies screens, interaction and edge cases. Actual 1280×720 renders, keyboard operation and reduced-motion behavior are required; a successful build is not visual evidence.

## 7. Scope and milestone exit

Prove the complete loop with **six species and one route**. Order: map/clarity → zones → growth/care/reserves → sheets/gear/discovery → authored encounter pacing → selected wagon/cargo depth. Older approved experiments follow the integrated foundation. Expand the bestiary after the species/kit/item schema settles.

Keep current sounds and settings, repairing missing feedback. No new regions, breeding, evolution tree, ranch building, crafting tree, multiplayer, cloud saves or public release in this milestone. Creature-created battlefield terrain remains rejected (B3). Dedicated creature art remains deferred.

The milestone is done when:

1. Fresh solo Discovery and prepared four-member expeditions complete/resume without forced resources or events.
2. Collect → equip → position → battle XP → injury → care/exchange → next route works end to end and is understandable.
3. At least two builds solve encounters differently. An early mistake is recoverable without mandatory restart/grind.
4. A purposeful gathering/search detour fits a reasonable delivery plan; fighting/care do not consume all exploration time.
5. Saves cannot duplicate XP/loot or lose individuals/items. Old journeys and active fights finish correctly.
6. No clipping, color-only warnings, hidden essential costs or unclear target/arrival behavior; keyboard/click help matches hover.
7. Evidence records seeds, policies, opportunities/fights, combat seconds, recovery costs, exploration, food lows and outcomes. Simulated time is not substituted for human playtime.

This establishes a coherent playable expedition, not a finished 300-species world or public release.
