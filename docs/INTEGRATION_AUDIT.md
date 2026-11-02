# One expedition, three influences

November 2, 2026. Fresh reference research and code audit against main `4a486fe536c86f3b23de5fdca5b4b0a443044495`. UI changes accompany this audit; proposed mechanics do not. Owner decisions: [integration-1](../reviews/integration-1.html).

## Verdict

Trailomon now has the right structural blend: Oregon Trail supplies the journey and scarcity, creature collecting supplies attachment and future crew choices, and Astronarch supplies battle preparation and automatic execution. The weakness is the connection between discovery, party building and the next encounter. More systems or more frequent fights would not automatically fix that.

The November 1 identity audit describes an older game. Its shared Resolve, once-only skills, exchange limits and combined opponent are no longer the new-journey combat model. Its 75/25 estimate was subjective; its combat-command percentages came from the old rules. Neither is a current measurement. No new playtime percentages or human fun scores are claimed here.

## Reference lessons

**Oregon Trail, weighted most heavily:** the 1985 Apple II manual ties pace, rations, weather, health, progress and crossing risks together. Resting and trading consume time; supply stops create preparation pressure. This is the useful design inheritance: a small set of interacting constraints can produce different stories. We are specifically using the 1985 model, not attributing all its features to the 1971 original. [MECC manual, printed pp. 8–10 and 35–36, preserved scan](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/educational/mecc/documentation/MECC-A157%20The%20Oregon%20Trail%20manual.pdf).

Later Oregon Trail editions expand reference material and subsistence choices. The 5th Edition guide includes a guidebook, diary, hunting, fishing and gathering. Borrow useful information and contextual resource decisions, while keeping our smaller interface and expedition scope. This is a secondary reference, not the target feature count. [Publisher's 2001 guide, pp. 15–28](https://device.report/m/653e100d2b2185b224da704a930cacd3ac83e5802458f19685a6bf32e7c1dd15.pdf).

**Pokémon Red/Blue:** exploration, capturing for the Pokédex, trainers, Gyms and trading connect discovery with a growing collection and repeated team tests. The important transfer is that a new creature changes what the player wants to try next. Our non-capture invitations can deliver that feeling. Multiplayer trading, Gym structure and an elemental chart are not necessary to do so. [Nintendo's Red description](https://www.nintendo.com/en-gb/Games/Game-Boy/Pokemon-Red-Version-266109.html).

**Astronarch:** its developer emphasizes distinct heroes, positioning, items that change builds, and paths with different enemies. Its published scope—21 heroes, 130+ items and 100+ encounters—is much broader than our six kits, three items and two road opponent templates. Automatic attacks alone reproduce only part of the design; useful preparation requires varied situations to prepare for. [Developer's Steam description](https://store.steampowered.com/app/1234940/Astronarch/).

## What overlaps in the current code

| Connection | Implemented now | Missing connection / best use |
| --- | --- | --- |
| Journey → battle | Condition sets starting HP; active travelers pay 6 Energy once; wagon damage and supplies settle into the expedition | Strong integration. Explain HP, Focus and Energy without creating another permanent meter. |
| Battle → journey | Injury can cost medicine, meals and a recovery day; repair also rests new-rule crews; peaceful options avoid battle costs | Keep fighting optional. A win is preserving the expedition, not a mandatory XP faucet. |
| Discovery → collection | Six habitat-grounded species, observed/known/traveled guide states, searches and invitations; eligible travelers retained between trips | Full crew can block the payoff after helping a species. A persistent earned invitation could preserve the discovery without increasing active party size. |
| Collection → builds | Three active travelers, six repeating kits/passives, formation, three equipment tradeoffs, horizontal habits | Few meaningful encounter tests; collection is not yet a broad team-building game. S32/S33 already authorize complementary abilities and a local adaptation. |
| Route → preparation | Terrain/distance costs, weather, last shop/shelter, travel assistance and gear advice in existing reports | Reports explicitly lack encounter information. Learned threat behavior could make this an actual combat-preparation decision, without predicting the RNG. |
| Habitat → combat identity | Wildlife habitat and individual creature abilities; new road opponents use species art/names | Both road fights still use the raider/caller behavior foundation. Their different HP and names do not create two fully distinct ecological challenges. |
| Replay → knowledge | Seeds, branches, discoveries, retained companions, journal aims/history, wagon unlock and learned habits | Expand useful options and knowledge before adding levels, currencies or grind. 300 is the future roster goal; only six are implemented. |

Source anchors: `simulation/wagon_road.lua`, `simulation/wagon_combat.lua`, `content/ambush.lua`, `simulation/recovery.lua`, `simulation/discovery.lua`, `simulation/tracking.lua`, `simulation/field_guide.lua`, `simulation/trail_reports.lua`, `simulation/progression.lua` and `simulation/habits.lua`.

## Evidence from the unchanged gameplay build

The [latest two rendered full journeys](../reviews/journey-2.html) remain relevant: this pass changes presentation, not simulation. Both used fresh Discovery profiles, seed 1848 and two searches. The recovery-heavy journey delivered on day 26; the prepared journey on day 24. That supports selective exploration, not a claim that every detour is affordable.

The early solo attempt retreated after 28 simulated seconds with 19/116 HP despite medicine. The prepared three-creature guardian battle ended in 16 simulated seconds: Loamling exposed targets, Brindlehorn shielded/intercepted, and Bellmoth interrupted. This demonstrates interactions and a large solo/team difference, not proven Astronarch-level depth or measured human enjoyment. S10 physical input, listening, real-time pacing and activation reliability remain open.

Helping Cindercoil used medicine, but its invitation then met a full three-member crew. That is the clearest collection disconnect. Two searches produced observations, while the party that already worked remained the party to keep. Adding hundreds of encounter entries would multiply this problem without resolving it.

## Three bounded integration options

**I1 — Remembered invitations.** First implement Cindercoil's existing help/return chain. If its invitation is earned while the crew is full, explicitly accept a rendezvous at the depot; commit that option at the expedition ending. Keep the three active slots, existing aid requirements and no reward for merely seeing tracks. Test full crew, decline, duplicate offers, return/rescue endings and save boundaries. One small system PR. Recommended first: collection should pay off before adding more species.

**I2 — Learned threat notes in existing route reports.** Add compact observed behavior alongside habitat clues and existing crew/gear advice. Separate “observed” from “reported”; show unknowns deeper in the wilderness. Preview tendencies, never tomorrow's roll, guaranteed species or automatic best-team instructions. Start with the two current road threats. One bounded knowledge/UI PR. This extends existing reports; S35's weather/migration pool remains separately approved.

**I3 — Two genuinely different road battle plans.** Give the existing food-raider and territorial-guardian encounters distinct behavior/formation tests: an interceptable supply rush versus a shielding defender and interruptible caller, with explicit counterplay and peaceful exits. Use existing creatures and gear. Keep encounter frequency, delivery deadline and XP/reward structure unchanged initially. One larger combat PR with matched solo/pair/trio and whole-trip checks. Coordinate with I2 so preparation clues describe real behavior.

If approved: I1 first, the already-approved S32 pairing next, then I2/I3. Each proposal is independently useful; no implementation is authorized by this document alone.

## What to retain, reconsider and defer

- Retain the shared expedition economy, small crew, persistent injuries, free inspection, finite gathering and quiet alternatives. These prevent battles becoming an unrelated minigame.
- Keep old combat resolvers as compatibility code. Do not expose their descriptions in new-journey equipment/ability views, and do not delete them without a save migration.
- Trust is still an inert number. A3 already proposes hiding it; it remains unanswered. This audit does not duplicate that vote or remove its saved field.
- Generic duty/habit controls need a visible consequence before more layers are added. S33 is the approved place to test a specific local adaptation; no universal class/type system.
- Do not add battle XP, evolution, breeding, crafting or a hunting minigame merely for resemblance. S34 already authorizes one food-web encounter/trade slice; S35 migration and S36 authored roster batches are also approved.
- D4 Mara variety and D5 collection aims remain on their original page. A2 Discovery default and E1/E2 balance choices likewise remain open. No answered idea is re-proposed.

## Clarity shipped with this audit

Crew rows distinguish Road and Combat using existing semantic icons. “Abilities & story” shows the current kit's active effect, passive and repeating Focus cost, with one short HP/Energy explanation; older journeys retain their own encounter wording. Camp has a direct crew-treatment link. “Playback” replaces the ambiguous view-speed label, and the delivery/closure days stay visible beside the current day.

No engine settings, art, save format or balance changed. An apparent sidebar problem in the image preview was disproved by identical original/final PNG hashes and a full sidebar pixel comparison; no speculative renderer workaround was retained.

Validation: 154 simulation checks plus native persistence/GUI, six-kit and legacy description checks, cost-free navigation/playback checks, and affected 1280×720 rendered screens. Evidence under `reviews/evidence/integration-1/`. Complete expeditions and broad balance matrices were reused rather than repeated because their gameplay inputs are unchanged.
