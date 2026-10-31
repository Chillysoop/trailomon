# Trailomon first playable

Run `Trailomon.exe` beside the four `game.*` data files. This is an offline Windows build; the Defold editor is not required. Unzip the whole folder before starting.

New expeditions use the guardian's readable four-exchange sequence: cargo shove, harmless warning, heavy approach rush, heavy cargo rush. Ordinary actions cost 3 energy, abilities add 6 once, and the warning costs 1. Existing saved journeys retain their earlier rules until the next expedition. To inspect the sequence directly, begin a journey, press F3 and choose **Guardian pattern / test encounter**, then **Secure passage**.

## Take a journey

Choose one or two companions at Fernwake Depot, within the seven-point crew budget. Bring a draft companion: Brindlehorn or Reedskipper initially. Buy supplies, then begin the journey. The default crew and loadout are playable starting choices.

Press **Space** or choose **Follow the road** to travel. Important events and landmarks stop the clock. Opening a menu or moving focus to another window also pauses the wagon. **Calm** speed presents a day in twenty seconds; **brisk** uses 2.5 seconds. Both use the same daily rules.

Deliver the orchard cuttings by day 26 if possible. The road closes on day 32. Cargo condition affects the delivery result, and arrival after day 26 can still bring the companions home. You can also request assistance from the travel screen to end a difficult trip.

Use **Crew** to rotate haulers, set duties, treat injuries, rename companions, and read memories. Camp actions cost a day and meals. Foraging can find food, but each stretch depletes. The landscape changes from nursery rows and maintained tracks to sparse cairns and open high country. Landmark screens show the place alongside its choices. Mossbell is labeled as the last supply shop, and Cairn Gate as the last maintained shelter. Mossbell is the only intermediate supply shop. Willowford offers a reliable paid ferry and riskier alternatives.

**Camp → Gather nearby provisions** opens the day's preview: food found, carrying room after meals, food packed, creature energy spent, and expected net provisions. Confirm once to spend the day; the journal records the actual receipt. **Journal → Symbol guide** explains all resource, role, and action marks. In combat, each ability now states its next trigger or the reason it will not fire; the result connects remaining energy to the crew's next job.

Battles are optional. Choose up to two companions and their positions: approach for pressure, wagon for cover. Each species acts automatically, with one additional ability when its visible trigger occurs. Use Pause or Space to inspect, Step exchange to advance once, and Resume to watch. Calm runs at five seconds per exchange; brisk at 1.5. Menus, focus loss, and loading pause combat. Withdraw before the next exchange to pay the displayed loss once. The result screen shows actual energy, condition, cargo, provisions, and days spent. Older saved manual encounters keep their original action buttons until finished.

Two original species can join after you help them on the trail. Companions, observations, and memories persist across expeditions. Inspecting and crossing Willowford unlocks a covered wagon after that trip ends. The cover protects against rain but reduces carrying capacity.

## Controls and saves

- Mouse: select labeled controls.
- Space: resume or pause travel and automatic combat.
- Tab / arrows: move keyboard focus; Enter: activate.
- Escape: return to the journey or cancel text entry.
- F3: developer controls, including forced encounters and resupply. These alter the active trip and are intended for testing.

The game saves after decisions, completed days, and exchange boundaries. Options includes a manual Save action. Save failures are shown in the footer. Keep the application open if a save error appears and retry when local storage is available.

Saves use Defold's application save directory for `trailomon`, with an active snapshot and a last-good backup. A damaged active save loads the backup with a recovery message. If both files fail validation, the game offers an explicit fresh start. Test scripts use a separate namespace.

## What this build covers

One six-landmark route with two branches, six creature species, eighteen event definitions, two battle scenarios, weather, resource management, recovery, recruitment, two wagon configurations, saved companions, a field journal, and repeatable seeds. Menus include labeled original pixel icons for resources, roles, and actions.

This is an early playable for checking the decisions and rhythm. Creature art uses selected Sprite Fusion studies with simple procedural motion. Detailed frame animation, final anatomy and camera consistency, finer scenery detail, ambient music, and broader content are still art and polish work. The visual rules in `docs/VISUAL_DIRECTION.md` remain requirements for those passes.

For feedback, note the seed and the decision involved. Most useful: whether a cost was unclear, a creature felt unnecessary, a setback felt arbitrary, a quiet stretch felt too long, or you wanted to try a specific different plan afterward.

For isolated developer fixtures, run `./tools/test.ps1 -Fixture scavengers` (or `territorial`, `legacy`) and launch the release executable using the printed save namespace. Use the release renderer locally; `-Headless` is intended for CI and can start Defold debug services on Windows.
