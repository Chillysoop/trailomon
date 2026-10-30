# Trailomon first playable

Run `Trailomon.exe` beside the four `game.*` data files. This is an offline Windows build; the Defold editor is not required. Unzip the whole folder before starting.

## Take a journey

Choose one or two companions at Fernwake Depot, within the seven-point crew budget. Bring a draft companion: Brindlehorn or Reedskipper initially. Buy supplies, then begin the journey. The default crew and loadout are playable starting choices.

Press **Space** or choose **Follow the road** to travel. Important events and landmarks stop the clock. Opening a menu or moving focus to another window also pauses the wagon. **Calm** speed presents a day in twenty seconds; **brisk** uses 2.5 seconds. Both use the same daily rules.

Deliver the orchard cuttings by day 26 if possible. The road closes on day 32. Cargo condition affects the delivery result, and arrival after day 26 can still bring the companions home. You can also request assistance from the travel screen to end a difficult trip.

Use **Crew** to rotate haulers, set duties, treat injuries, rename companions, and read memories. Camp actions cost a day and meals. Foraging can find food, but each stretch depletes. Mossbell is the only intermediate supply shop. Willowford offers a reliable paid ferry and riskier alternatives.

Battles are optional. Choose up to two companions, read the threat's next intent, and select one action per companion. Pressure costs stamina, Guard protects the acting companion and cargo, and Assist is once per companion per encounter. Clear selected actions before choosing Withdraw. Battles have short round limits and no experience grind.

Two original species can join after you help them on the trail. Companions, observations, and memories persist across expeditions. Inspecting and crossing Willowford unlocks a covered wagon after that trip ends. The cover protects against rain but reduces carrying capacity.

## Controls and saves

- Mouse: select labeled controls.
- Space: resume or pause travel.
- Tab / arrows: move keyboard focus; Enter: activate.
- Escape: return to the journey or cancel text entry.
- F3: developer controls, including forced encounters and resupply. These alter the active trip and are intended for testing.

The game saves after decisions, completed days, and battle rounds. Options includes a manual Save action. Save failures are shown in the footer. Keep the application open if a save error appears and retry when local storage is available.

Saves use Defold's application save directory for `trailomon`, with an active snapshot and a last-good backup. A damaged active save loads the backup with a recovery message. If both files fail validation, the game offers an explicit fresh start. Test scripts use a separate namespace.

## What this build covers

One six-landmark route with two branches, six creature species, eighteen event definitions, two battle scenarios, weather, resource management, recovery, recruitment, two wagon configurations, saved companions, a field journal, and repeatable seeds. Menus include labeled original pixel icons for resources, roles, and actions.

This is an early playable for checking the decisions and rhythm. Creature art uses selected Sprite Fusion studies with simple procedural motion. Detailed frame animation, final anatomy and camera consistency, richer landmark art, ambient music, and broader content are still art and polish work. The visual rules in `docs/VISUAL_DIRECTION.md` remain requirements for those passes.

For feedback, note the seed and the decision involved. Most useful: whether a cost was unclear, a creature felt unnecessary, a setback felt arbitrary, a quiet stretch felt too long, or you wanted to try a specific different plan afterward.
