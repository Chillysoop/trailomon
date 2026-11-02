# Four companions and a wider collection

Owner direction, November 2, 2026. The active party can contain up to four individual companions. The persistent collection has no game-imposed count cap and permits duplicate species. Six species are playable; this does not create the planned 300-species index content.

## Playable rules

- Existing invitations now collect an individual even when the party is full. The existing food/help costs still apply. A free party slot admits the new friend; a full party sends it to the depot reserve. The choice and receipt state the destination.
- Individuals have stable numeric identities, separate names, memories, habits and journey condition. Duplicate species may travel and fight together with separate clocks, HP, Focus and gear.
- At Fernwake, choose up to four from the paged Collection screen. Store one before replacing it. A hauler is still required. The old two-member/seven-point departure budget is replaced for collection-enabled journeys. Fresh company now records solo, duplicate-pair and larger departure compositions while preserving old pair records.
- Reserves do not eat, haul, assist, fight, or replace injured travelers mid-expedition. Party swaps happen before departure. Storing a companion unassigns its item; the item remains packed exactly once.
- Collecting is saved immediately with the existing transactional game save. Delivery, voluntary return, rescue and replay do not duplicate or erase ownership. Ending a trip restores returning companions as before and remembers the chosen party for the next departure.
- Existing saves gain individual records on load without rerolling pending events or changing a saved battle. Old combat and recovery rules continue for those trips. Historical test fixtures explicitly retain the previous collection rules.

## Wayhome Commons and waybeds

The owner's follow-up **Proceed** accepts the recommended C1–C3 direction. Wayhome Commons is a neglected animal waystation behind Fernwake. Creatures bring its empty habitats back to life; they need not earn their place through work. Collection → About the Commons shows the resident ledger and first homecomings. This is a functional ledger with short writing, not a walkable ranch or construction simulation.

Loamling follows a visible root trail into a straw waybasket; Bellmoth chooses a shaded roost cloth with a meal. Each is one choice, the existing 4-food cost, a settling receipt, and an individual record. No extra day, hidden affection roll, new inventory material or knock-out requirement. Encounter/choice IDs and costs stay stable so pending old invitations still resolve. Cindercoil/Slatewhorl keep their rescue chains; Brindlehorn/Reedskipper keep their existing meetings. All six now have a habitat, waybed and homecoming vignette; the next bespoke encounter treatments can follow the first two.

Four travel; reserves receive safe off-screen roadkeeper escorts to the Commons in their waybeds. Their food and transport are included, with no extra turn. They cannot replace active travelers mid-trip. This is an explicit fiction for the existing reserve abstraction, not simulated traffic or a way to teleport cargo.

Story buttons show each individual's meeting event, journey/day, route area, home habitat and waybed. Returning active friends receive a first-homecoming record at any ending; escorted reserves receive theirs immediately. Only the first arrival of each species establishes its Commons vignette; duplicates retain separate origins. Existing friends receive honest unrecorded origins, without inventing their history. These records never modify combat, recovery, RNG or the original bounded memories. The Foldyard alternative was not selected; no universal capture item, ranch building, new art or affection grind is included.

The owner's four-member collection request supersedes integration-1 I1's narrower three-member Cindercoil rendezvous. I2/I3 remain unanswered.

## Validation and limits

164 Lua scenarios; native saves/backup recovery including 1,000 individual records and a resumed four-member fight; native collection navigation/selection/locking and four-member care; legacy resolver tests retained. Eleven affected screens were rendered at 1280×720 using production callbacks, including Discovery starter choice, paging, full-party invitation, duplicate-species combat, gear, habits and old combat selection. Crowded fourth-row/sidebar labels were corrected. [Evidence](../reviews/evidence/collection-1/collection_roster.png).

Eight bounded full expeditions (seeds 11, 73, 1848, 2047; reference-v1+road-receipts+wagon-v1 careful/fighter policies), each replayed exactly, started with Brindlehorn, Loamling, another Brindlehorn and Bellmoth. All terminated: one on-time delivery, five late arrivals, two rescues; 6–7 collected individuals at the end. This deliberately full-party default provisioning sample exposes food/time pressure, not a human fun rating or a fair comparison against an optimized crew. No enemy, food or deadline rebalance was silently applied. S5 should evaluate provisioning and exploration time with the new four-member option. [Run values](../reviews/evidence/collection-1/journeys.json); capture metadata records source fingerprints and dirty working revision.

Six Python report tests, 22 review tests and an isolated browser fixture cover YES/NO, notes, autosave, FINISH, history and phone/dark fallback. UI evidence does not test physical input or listening. Existing S10 hands-on gaps remain open.
