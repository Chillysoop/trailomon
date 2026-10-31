# Trailomon first playable

Run `Trailomon.exe` beside the four `game.*` data files. This is an offline Windows build; the Defold editor is not required. Unzip the whole folder before starting.

New expeditions use the guardian's readable four-exchange sequence: cargo shove, harmless warning, heavy approach rush, heavy cargo rush. Ordinary actions cost 3 energy, abilities add 6 once, and the warning costs 1. Existing saved journeys retain their earlier rules until the next expedition. To inspect the sequence directly, begin a journey, press F3 and choose **Guardian pattern / test encounter**, then **Secure passage**.

## Take a journey

Choose one or two companions at Fernwake Depot, within the seven-point crew budget. Bring a draft companion: Brindlehorn or Reedskipper initially. Buy supplies, then begin the journey. The default crew and loadout are playable starting choices.

For a discovery-led start, choose **Options → Open discovery depot**. This keeps a separate save. Pick Brindlehorn or Reedskipper before your first departure, then meet Loamling at Split Oak and Bellmoth at Mossbell. Their optional invitations each cost four provisions, with the extra daily meals shown before you accept. Recruited companions stay available for later trips. Switch back through Options to resume the Classic depot. To meet the other starting hauler, choose **Wildlife nearby** at Split Oak (Brindlehorn) or Willowford (Reedskipper). Meeting takes no time; invitation costs four provisions and needs a free crew space.

Press **Space** or choose **Follow the road** to travel. Important events and landmarks stop the clock. Opening a menu or moving focus to another window also pauses the wagon. **Calm** speed presents a day in twenty seconds; **brisk** uses 2.5 seconds. Both use the same daily rules.

Deliver the orchard cuttings by day 26 if possible. The road closes on day 32. Cargo condition affects the delivery result, and arrival after day 26 can still bring the companions home. You can also request assistance from the travel screen to end a difficult trip.

Use **Crew** to rotate haulers, set duties, treat injuries, rename companions, and read memories. Camp actions cost a day and meals. Foraging can find food, but each stretch depletes. The landscape changes from nursery rows and maintained tracks to sparse cairns and open high country. Landmark screens show the place alongside its choices. Mossbell is labeled as the last supply shop, and Cairn Gate as the last maintained shelter. Mossbell is the only intermediate supply shop. Willowford offers a reliable paid ferry and riskier alternatives.

**Camp → Gather nearby provisions** opens the day's preview: food found, carrying room after meals, food packed, creature energy spent, and expected net provisions. Confirm once to spend the day; the journal records the actual receipt. **Journal → Symbol guide** explains all resource, role, and action marks. In combat, each ability now states its next trigger or the reason it will not fire; the result connects remaining energy to the crew's next job.

**Crew → Work items** buys and assigns the padded trace, release rope and dry wrap. The depot and Mossbell also link to this page. Items use coins and carrying room; one slot per companion. Swap only while stopped outside an encounter. Returns are available before departure. Items are packed afresh for each journey.

Battles are optional. Choose up to two companions and their positions: approach for pressure, wagon for cover. Each species acts automatically, with one additional ability when its visible trigger occurs. Use Pause or Space to inspect, Step exchange to advance once, and Resume to watch. Calm runs at five seconds per exchange; brisk at 1.5. Menus, focus loss, and loading pause combat. Withdraw before the next exchange to pay the displayed loss once. The result screen shows actual energy, condition, cargo, provisions, and days spent. Older saved manual encounters keep their original action buttons until finished.

Two original species can join after you help them on the trail. Companions, observations, and memories persist across expeditions. Inspecting and crossing Willowford unlocks a covered wagon after that trip ends. The cover protects against rain but reduces carrying capacity.

Wild sightings offer **Watch**, **Help**, or **Pass** along suitable habitats. **Journal → Species field guide** distinguishes known species, wild sightings, and companions you have traveled with. Records are kept when a journey ends, including an early return.

Meet courier Mara at Split Oak, then find her again at Mossbell. Her optional practice uses the same automatic combat and spends real crew energy, but damages a practice load instead of your cargo or companions. You can skip, leave setup, or withdraw freely. She remembers help and completed practice across trips. An actual practice exchange counts as combat for the peaceful-journey aim.

After three well-fed working travel days, a companion learns a habit. Choose **Crew → Learned habits** at the departure depot to turn it on or off. Each habit offers a travel benefit and a cost; it is optional and never adds combat levels. Habit progress and selection remain with that companion between journeys.

## Controls and saves

- Mouse: select labeled controls.
- Space: resume or pause travel and automatic combat.
- Tab / arrows: move keyboard focus; Enter: activate.
- Escape: return to the journey or cancel text entry.
- F3: developer controls, including forced encounters and resupply. These alter the active trip and are intended for testing.

The game saves after decisions, completed days, and exchange boundaries. Options includes a manual Save action. Save failures are shown in the footer. Keep the application open if a save error appears and retry when local storage is available.

Saves use Defold's application save directory for `trailomon`, with an active snapshot and a last-good backup. A damaged active save loads the backup with a recovery message. If both files fail validation, the game offers an explicit fresh start. Test scripts use a separate namespace.

Classic uses `expedition_v1`; Discovery uses `discovery_v1`. Each has its own backup. `depot_selection` remembers which to reopen. Switching saves the current depot first; a failed save stops the switch.

## What this build covers

One six-landmark route with two branches, six creature species, twenty-eight event definitions, two road battle scenarios plus courier practice, weather, resource management, recovery, recruitment, two wagon configurations, two separate depot modes, saved companions and habits, a field journal, and repeatable seeds. Menus include labeled original pixel icons for resources, roles, and actions.

This is an early playable for checking the decisions and rhythm. Creature art uses selected Sprite Fusion studies with simple procedural motion. Detailed frame animation, final anatomy and camera consistency, finer scenery detail, ambient music, and broader content are still art and polish work. The visual rules in `docs/VISUAL_DIRECTION.md` remain requirements for those passes.

For feedback, note the seed and the decision involved. Most useful: whether a cost was unclear, a creature felt unnecessary, a setback felt arbitrary, a quiet stretch felt too long, or you wanted to try a specific different plan afterward.

For isolated developer fixtures, run `./tools/test.ps1 -Fixture scavengers` (or `territorial`, `legacy`) and launch the release executable using the printed save namespace. Use the release renderer locally; `-Headless` is intended for CI and can start Defold debug services on Windows.

At Split Oak and Cairn Gate, read the trail report before choosing a route. Known terrain is separate from uncertain conditions; crew and work-item advice updates with your preparations. Reading takes no time.

Earlier choices can return later: clearing the fallen tree lets a grateful cart catch up; a temporary axle lashing can slip on rough travel unless repaired. The road pauses to explain each result. Continue closes the message without spending time.

**Journal > Optional aims** tracks three accomplishments across trips: deliver on time with two different departure species pairs, reach Lantern Reach along both final paths, and arrive without a combat exchange. Late arrivals count for paths and peaceful travel; early returns do not. Inspection and withdrawal before the first exchange are peaceful. Recruitment and renaming do not change a departure pair. All aims track automatically, persist beyond the ten-trip history, and award journal entries without stat bonuses. Departure and ending screens also link to them. Old saves recover provable arrival paths; crew/combat tracking begins on the next departure.

**Journey → Wildlife nearby** opens a free preview while stopped outside encounters. **Follow these tracks** spends one day and the displayed meals. One search per stretch; the clue and hidden result are saved when you enter the stretch. Some tracks end at empty shelter. Passing or reopening menus costs nothing, and reloads cannot reroll the result. The day uses normal weather and recovery; any invitation or assistance afterward shows its own additional cost. Searches require enough food and stop before the last closing day.

**Journal → Species field guide** now gives habitat and method hints, separating unconfirmed reports from firsthand sightings. Existing saved journeys keep their original rules and enable searches on the next departure. The new hauler meetings are available in existing Discovery journeys when you reach their landmarks.
