# Reports at the forks

October 31, 2026 — N9 / S18.

Split Oak and Cairn Gate now show a compact report before the player commits to either branch. Reading costs nothing. Crew and work-item preparation remains available, as do resting at the oak and camping at the gate. All four routes retain their original travel rules.

## What the player can know

- Known terrain: distance, speed modifier, first gathering yield, and the ridge's extra wagon wear and hurried cargo loss. Fork distances come from the same content definitions used by departure.
- Uncertain outlook: Split Oak uses only today's observed weather. It never claims to know tomorrow, a future encounter or the route's hidden rolls. Cairn Gate has no fresh report beyond the shelter and explicitly gives less information.
- Preparation: advice uses the current crew, energy, condition, working duty, and packed/equipped work items. It explains limitations: padded trace saves hauling energy, not ridge wear; dry wrap helps its wearer, not cargo. Loamling's gathering contribution still costs energy, a day and meals.

No new forecast probabilities, scouting purchase, events, maps, random stream or save fields. Resting can change the observed conditions. Reopening, saving/reloading or changing menus cannot reroll anything. Meadow and woodland have equal base gathering yields; the previous woodland label implied a bonus that did not exist and has been corrected.

## Focused validation

70 Lua scenarios pass, including six new report scenarios. These check repeated reads and whole-snapshot immutability, no future-RNG dependency, older snapshots, actual terrain effects, current readiness, equipment transfers, and 48 matched branch/day continuations (12 seeds × four routes). Existing full-journey regression results remain unchanged.

Native persistence and the existing 36 GUI states pass. Added interactions activate each route using the production keyboard handler, open crew preparation without passing time, rest at the oak and open camp at the gate. These are scripted checks, not physical keyboard or listening tests.

Four real 1280×720 captures cover both forks, rainy equipment advice and an unavailable Cindercoil duty. The first compact scene let wagon/creature sprites overlap the heading; using the existing landscape strip fixed the overlap without altering the main journey scenery. Evidence and exact input hashes: `reviews/evidence/trail-reports-1/`.

This update does not establish optimal route balance. Woodland's current benefit needs a later design/balance review rather than an unapproved numerical change. The known Windows activation fault, listening and human pacing remain milestone checks. Next approved work: N10's two short event consequence chains, then N11's optional journal aims.
