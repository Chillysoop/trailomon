# Trailomon plan

Updated October 30, 2026. Owner-approved scope: one polished expedition first, Windows only. Defold and Lua remain the engine and language. The existing playable foundation is merged in [PR 1](https://github.com/Chillysoop/trailomon/pull/1).

## Pitch

Trailomon is a calm expedition game about one traveler, a wagon, and a small crew of original creatures venturing into increasingly unexplored wilderness. Prepare supplies, choose routes, gather resources, and care for companions whose abilities help with travel and short automatic battles. Combat rewards preparation, positioning, and complementary abilities. Each journey leaves discoveries, relationships, and new options for another departure. Deliberate pixel art and consistent labeled icons give the world a recognizable identity.

## Core loop

Prepare a crew and load at Fernwake, travel toward a landmark, observe changing conditions, choose an approach to a problem or opportunity, recover or resupply, and continue toward Lantern Reach. At an ending, retain eligible companions, discoveries, and memories and prepare another trip.

During a typical half-minute the player watches the wagon travel, reads a change in circumstances, or makes one consequential choice. Important decisions pause time. Automatic combat replaces new manual battles and remains a short part of the journey. Astronarch is the primary combat reference; Automon informs the creature-party appeal.

## Pillars

1. Let the road breathe. Quiet travel and animal behavior belong between consequential decisions.
2. Make preparation matter. Time, supplies, load, fatigue, and weather create understandable tradeoffs.
3. Give every companion a life and a useful body. The same adaptations explain travel help and combat behavior.
4. Carry the player farther from dependable help. Scenery, reports, and route demands express increasing remoteness.
5. Make another journey worthwhile. Different crews, conditions, discoveries, and horizontal unlocks support replay without mandatory grinding.

## Systems and content target

| Area | First polished expedition |
| --- | --- |
| Journey | One complete route, six landmarks, two branch choices, one river crossing; target 20–35 minutes |
| Crew | Six original species; one or two at departure and at most three traveling; two active in encounters |
| Combat | Two automatic scenarios with readable abilities and two positions; preserve peaceful alternatives and persistent costs; tune against the whole journey |
| Provisioning | Food, medicine, repairs, coins, cargo, and capacity; existing foraging with finite local yields; hunting deferred by approved P2 |
| Survival | Weather, pace, rations, hauling, stamina, injuries, wagon wear, and cargo condition |
| Progression | Named companions, discoveries, memories, ten journey summaries, and standard/covered wagon alternatives |
| Narrative | Give existing landmarks and species distinct ecological and local details within the current eighteen authored events |
| Usability | Clear goals, labeled icons, mouse and keyboard control, readable 1280 by 720 presentation, pause, save/resume, basic audio controls |
| Delivery | Offline Windows ZIP, launch instructions, exact source revision, repeatable build and test scripts |

The current game already implements the journey, automatic encounters, foraging, saving, and initial progression. See [GAME_DESIGN.md](GAME_DESIGN.md) for current rules, [AUTO_BATTLES.md](AUTO_BATTLES.md) for the reference study and future proposals, and [WORLD_LORE.md](WORLD_LORE.md) for creative possibilities. Proposal documents do not automatically add every idea to scope. Review votes and the [roadmap](ROADMAP.md) determine implementation priorities.

## Art and audio direction

Use intentional pixel art with strong silhouettes, a restrained earthy palette, and a coherent side view. The wagon and landscape lead the composition. Species anatomy must remain recognizable at travel scale. Reuse the original icon language across preparation, travel, gathering, encounters, and the journal; pair icons with labels and values. Follow [VISUAL_DIRECTION.md](VISUAL_DIRECTION.md).

The landscape becomes less maintained toward the uplands: fewer roofs, fading wheel ruts, larger horizons, and more wildlife-shaped landmarks. Lantern Reach is a small settlement at the edge of dependable travel. Larger wilderness regions belong to a later expansion.

Use restrained work sounds, weather, creature calls, and short feedback tones. Retain the existing sound and reduced-motion options, validate their persistence, and perform a listening review. New paid art generation requires the owner's spending approval under the project workflow; existing approved assets can be edited and integrated within the repository.

## Platform and scope boundaries

The first milestone supports Windows desktop, offline, with mouse and keyboard. macOS, Linux, and HTML5 are deferred by the owner's October 30, 2026 decision.

Defer additional regions, a large bestiary, breeding, evolution trees, capture devices, elemental charts, repeatable combat XP, permanent stat grinding, a crafting tree, base construction, multiplayer, online accounts, cloud saves, monetization, and a large narrative campaign. Equipment is approved as a small later experiment, scheduled after combat is readable and tested. Public releases and spending require explicit approval; ordinary tested PRs are merged by the developer.

## Open decisions

The owner approved P1–P5 in [plan-1](../reviews/plan-1.html) on October 30, 2026: automatic combat, bounded foraging with hunting deferred, wilderness presentation, six-species art refinement, and the three-item equipment experiment after combat testing. They then approved N1–N8 in [next-1](../reviews/next-1.html), prioritizing iconography and visible simplicity. Automatic combat, bounded-gathering clarity, the shared symbol system, and N2's forecasts/consequences are implemented; combat tuning and the other approved work retain their roadmap status. The current audit recommends N1 reporting, N8 whole-trip validation, then guardian tuning, wilderness/creature refinement, and equipment. No repeat approval is needed. Saved later answers and comments take precedence over initial recommendations. Blank ideas after FINISH are deferred without repeated prompting.

No reliable calendar estimate has been set. Ship small tested steps, measure the result, and revise content ambitions before promising dates. The owner's programming experience is unspecified; setup explanations should remain beginner-friendly.
