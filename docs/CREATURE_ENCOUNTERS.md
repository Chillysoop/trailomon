# Creatures and fellow travelers

October 31, 2026. W1–W6 approved in wild-1 revision 7; implementation status is tracked in the roadmap. Review: [wild-1](../reviews/wild-1.html). The owner wants more of the appeal of encountering, collecting and traveling with creatures, integrated with existing systems. Original species, the expedition economy and Astronarch-led automatic combat remain the foundation.

## Recommendation

Make creatures something the player anticipates along the road. A habitat suggests who might live there; meeting one offers a choice; the journal remembers what happened; another departure lets the player pursue a different discovery or crew. Human companion handlers make the inhabited road feel social, then become scarce as the route grows wilder.

Start with **W1 sightings, W2 field observations, W3 one courier spar**. These add discovery, collection and another creature crew without changing the delivery objective. W3 is substantially more work than W1/W2. Build and assess the wildlife slice before the spar; no calendar promise. W4â€“W6 are independent expansion choices, not prerequisites.

## What the game actually supports

| Existing foundation | Best extension | Important limit |
| --- | --- | --- |
| `content/events.lua`, `simulation/events.lua`: conditional authored events, seen flags, quiet-day cooldown, prioritized follow-ups | Habitat sightings and personal encounters | More events dilute the existing recruitment pool; do not simply increase event frequency |
| Cindercoil and Slatewhorl: help first, later invitation, food cost and meal preview | Make these relationships easier to anticipate | They already exist. Another copy of the same rescue is not a new system |
| Six species; four available at the first depot; two recruitable later | Encounter familiar species in the wild and show different lives | Seeing the starting four cannot currently unlock a new roster member |
| `simulation/progression.lua`: one companion per species, memories, discoveries, end-of-run commit | Separate field observations and named traveler recognition | No duplicate collection, roster of individuals, evolution or meaningful trust progression; the stored trust counter alone is not a bonding system |
| `simulation/combat.lua`: two player positions, species triggers, one enemy resolve value and an incoming intent | A bounded opposing-pair encounter with readable behavior | No second simulated team, enemy equipment/energy, or individual enemy targeting. True symmetric team combat is a larger redesign |
| Fork reports, terrain/weather, finite foraging, hauling and persistent fatigue | Wildlife opportunities that compete with time, supplies and crew readiness | Reports cannot truthfully promise future weather or peek ahead through the random stream |
| Journal aims, event consequences and saved flags | Observational collection and a recurring traveler | New records need persistence and old-save defaults; existing flags are not automatically a campaign relationship system |

## Proposed additions

### W1 â€” Habitat sightings (top pick)

Add three bounded wildlife scenes to the existing route: a Brindlehorn herd on meadow, Bellmoths at woodland shelter, and a Reedskipper reed platform near Willowford. Each has **Watch / Help / Pass** where appropriate. Watch records a sighting without a supply reward; help has one previewed cost and a concrete response; passing is free. Use existing species art and short labeled icons. No forced battle or recruitment roll.

Replace generic ambient opportunities for these sightings rather than adding a new interrupt stream. If a sighting offers a consequential choice, it obeys the existing major-event cooldown. Each scene is once per journey, not farmable by camping. Cindercoil/Slatewhorl recruitment follow-ups retain priority. Phase-one habitats use existing terrain/route gates; weather can qualify a small authored variation, not simulate populations or migration.

**Cost:** smallâ€“medium: content, eligibility/selection changes, receipts and replay tests. **Value:** the road gains recognizable wildlife without extra survival pressure. With W2 declined, records use the current journey log only.

### W2 â€” Species field observations (top pick)

Add a compact Journal field guide for the six current species: **Known / Seen wild / Traveled with**, plus one learned habitat or behavior note per species. Known starting species are not falsely marked observed. Seeing a wild animal counts even if it never joins. Record current Loamling/Slatewhorl confrontations and Cindercoil/Slatewhorl discovery scenes too, so this option works without W1.

Persist genuine observations at journey resolution, consistent with existing discoveries, including a return or rescue. Show newly recorded observations in the run result. Keep the existing role guide; this is a species view, not a duplicate icon glossary. Replay motivation is learning and completion, without combat XP or a numerical collection bonus.

**Cost:** medium: a small observation map, old-save defaults, event hooks and Journal view. Existing boolean discoveries cannot distinguish ownership from a wild sighting, and historical facts cannot all be reconstructed. Older profiles keep their roster; unknown observations start unrecorded.

### W3 â€” One optional courier spar (top pick)

At Mossbell, meet a courier with a Brindlehorn/Bellmoth pair. Preview their roles and accept one short automatic practice encounter or pass freely. Use a **practice load** in place of orchard cargo, preserving the purpose of our wagon-protection abilities. Real energy is spent; practice harm scores against the exercise rather than damaging cargo or companion condition. Refusal and defeat do not block the road.

Prototype the opposing pair as two visible contributors to one shared Resolve track with a disclosed three-exchange pattern. Give each a meaningful effect: the Brindlehorn's shove tests cover; the Bellmoth's cover reduces one pressure exchange. Repel their resolve before the limit while protecting the practice load to win. This requires a new encounter kind, effect handling and outcome, not merely renaming the guardian. Keep player abilities, positions and viewing controls. A result note is the reward; no repeatable money or XP. One attempt per run, preview the effort budget before commitment.

**Cost:** mediumâ€“large: authored opponent behavior, practice-state isolation, forecasts, saves, UI and balance. The prototype deliberately does not promise fully independent enemy units. If that proves essential to the desired feel, review a larger two-team design afterward. W3 works without W1/W2; records use the current log/memories.

### W4 â€” A familiar fellow traveler

Make one named courier recur at two existing stops: a first meeting near Split Oak and recognition at Mossbell. They remember whether the player helped, passed or later spared energy for practice. Keep one bounded personal flag and one later acknowledgment, using the existing follow-up approach. No standings, universal reputation, timed race or adaptive team that secretly counters the player.

**Cost:** smallâ€“medium: two scenes, saved recognition and conditions. **Recommendation:** after W1â€“W3. If W3 is approved this is the same courier; otherwise the meetings remain social. This develops the rival/friend feeling without making human encounters crowd the remote final stretch.

### W5 â€” Discovery-led departure mode

For a new profile only, offer a separately selectable start with one chosen hauler (Brindlehorn or Reedskipper); meet and befriend Bellmoth and Loamling along the first route. Keep the normal four-species departure available and existing profiles intact. Preserve Cindercoil/Slatewhorl's current later recruitment. This changes collecting from discovering two additional species to assembling a crew through travel.

**Cost:** large: an alternate starting economy, two recruitment paths, guarantees against hauling/food soft-locks, profile labeling and full-run balance. The three-companion cap still matters; the first version must not require collecting everybody in one journey. **Recommendation:** later, if wildlife acquisition becomes a core priority. This is the most direct collection change, but it cannot safely be treated as a content-only tweak.

### W6 â€” One learned habit per companion

After a specific journey feat, let a companion select one bounded, clearly previewed travel habit at the depot. Example design space: save effort when scouting but spend more when hauling. Habits are alternatives with a cost, not permanent stat stacking; keep the existing three work items as separate physical equipment.

**Cost:** large: persistent per-companion choices, species-specific balance, interface and equipment interactions. **Recommendation:** defer until acquisition and encounters feel good. Current memories and the trust counter do not implement this. Duplicate creatures, breeding, evolution trees and elemental charts remain outside these proposals.

## How one journey might feel

Choose a hauler and scout at Fernwake. Spot a herd on the meadow and learn its call, or choose woodland for a different sighting. At Mossbell, decide whether the courier's spar is worth energy needed for Willowford. Farther out, people disappear; soaked shelter and shale tracks point toward the two existing recruitment stories. A third companion changes food needs and crew options. At the ending, the journal retains real observations and the next departure offers a different pairing or habitat to investigate.

This is a possible sequence, not a guarantee that every event appears. Recruitment helps the expedition but is never a prize automatically awarded for defeating wildlife.

## Integration and acceptance gates

- Reuse event IDs/flags, costs, the seeded event stream, recruitment previews, memories and end-of-run persistence. New state gets explicit version/default handling; existing journeys keep their rules where results would change.
- Maintain calm pacing: two quiet travel days after a major choice, no repeatable search/battle button, early optional human meetings and late wilderness emphasis. Do not hide supply costs behind lore.
- Keep the current crew cap and one companion per species. At full crew, retain the clear invitation limit and record the encounter; no remote roster swap or instant healing. A collection expansion may later warrant a separately designed full-crew recruitment solution.
- Reuse semantic icons and colors; short actions, costs and outcomes on screen, detailed ecology in the guide. Existing sprites suffice.
- For W1/W2 test habitat eligibility, no cooldown/recruitment starvation, deterministic replay, once-only records and save/resume. For W3 test practice cargo/condition isolation, real fatigue, each species trigger, skip/withdraw/exhaustion, old saves and actual forecast/result screens. Compare full journeys only when the new encounter changes resource balance.

The review approves only the bounded proposals above. It does not authorize new regions, a large bestiary, paid art, full symmetric combat, or a public release.
