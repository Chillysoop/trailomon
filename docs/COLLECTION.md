# Four companions and a wider collection

Owner direction, November 2, 2026. The active party can contain up to four individual companions. The persistent collection has no game-imposed count cap and permits duplicate species. Six species are playable; this does not create the planned 300-species index content.

## Playable rules

- Existing invitations now collect an individual even when the party is full. The existing food/help costs still apply. A free party slot admits the new friend; a full party sends it to the depot reserve. The choice and receipt state the destination.
- Individuals have stable numeric identities, separate names, memories, habits and journey condition. Duplicate species may travel and fight together with separate clocks, HP, Focus and gear.
- At Fernwake, choose up to four from the paged Collection screen. Store one before replacing it. A hauler is still required. The old two-member/seven-point departure budget is replaced for collection-enabled journeys. Fresh company now records solo, duplicate-pair and larger departure compositions while preserving old pair records.
- Reserves do not eat, haul, assist, fight, or replace injured travelers mid-expedition. Party swaps happen before departure. Storing a companion unassigns its item; the item remains packed exactly once.
- Collecting is saved immediately with the existing transactional game save. Delivery, voluntary return, rescue and replay do not duplicate or erase ownership. Ending a trip restores returning companions as before and remembers the chosen party for the next departure.
- Existing saves gain individual records on load without rerolling pending events or changing a saved battle. Old combat and recovery rules continue for those trips. Historical test fixtures explicitly retain the previous collection rules.

## Fiction still under review

[Collecting-1](../reviews/collecting-1.html) proposes the Wayhome Commons, species-specific waybeds/befriending, and arrival stories, with the Foldyard as a more magical alternate home. These proposals are not implemented or approved merely because the storage system exists. Current UI uses the neutral existing depot. The Commons' return escort and Foldyard's magical transport are proposed explanations, not simulated services. No ranch building, new art, capture items, affection grinding, hunting or release/delete control is introduced here.

The owner's four-member collection request supersedes integration-1 I1's narrower three-member Cindercoil rendezvous. I2/I3 remain unanswered.

## Validation and limits

164 Lua scenarios; native saves/backup recovery including 1,000 individual records and a resumed four-member fight; native collection navigation/selection/locking and four-member care; legacy resolver tests retained. Eleven affected screens were rendered at 1280×720 using production callbacks, including Discovery starter choice, paging, full-party invitation, duplicate-species combat, gear, habits and old combat selection. Crowded fourth-row/sidebar labels were corrected. [Evidence](../reviews/evidence/collection-1/collection_roster.png).

Eight bounded full expeditions (seeds 11, 73, 1848, 2047; reference-v1+road-receipts+wagon-v1 careful/fighter policies), each replayed exactly, started with Brindlehorn, Loamling, another Brindlehorn and Bellmoth. All terminated: one on-time delivery, five late arrivals, two rescues; 6–7 collected individuals at the end. This deliberately full-party default provisioning sample exposes food/time pressure, not a human fun rating or a fair comparison against an optimized crew. No enemy, food or deadline rebalance was silently applied. S5 should evaluate provisioning and exploration time with the new four-member option. [Run values](../reviews/evidence/collection-1/journeys.json); capture metadata records source fingerprints and dirty working revision.

Six Python report tests, 22 review tests and an isolated browser fixture cover YES/NO, notes, autosave, FINISH, history and phone/dark fallback. UI evidence does not test physical input or listening. Existing S10 hands-on gaps remain open.
