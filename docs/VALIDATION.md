# First playable validation — October 30, 2026

The Windows release was exercised at 1280 × 720 using an isolated `trailomon_qa` save namespace. The firewall prompt from the earlier debug engine was dismissed by the user; subsequent local runs use the release engine.

## Journey exercised in the actual game

Seed 1848, Brindlehorn and Loamling, steady pace and normal meals, meadow and ridge branches. Completed the delivery on day 25 with 94% cargo integrity and three companions home.

- Preparation, departure, visible resource/role/action icons, menus, map, journal, and reduced-motion setting.
- Disabled Bellmoth choices; scavenger team selection, Guard, Pressure, one-use Assist, complete rounds, and returning to travel.
- Closed and reopened mid-battle: round, intent, cargo damage, stamina, and used Assist persisted.
- Rest consumed one day and the displayed meals; recovered companion stamina and condition.
- Mossbell purchase added ten food for six coins without advancing time.
- Helping and recruiting Cindercoil consumed the displayed supplies, added a third companion, and raised daily meals from three to four.
- River inspection used no time; ferry crossing used twelve coins, one day, and four meals.
- Territorial encounter withdrawal used a one-day detour and its meals.
- Delivery result, replaying the same seed, retained Cindercoil, and the covered-wagon unlock.
- Covered-wagon capacity rejection; foraging at 131/132 load packed four food after three meals, producing the displayed +1 net.
- Seed dialog cancellation; corrected camp layout; voluntary return and a map that leaves unvisited stops unreached.

## Fixes from this pass

- Battle start and round resolution wait for complete selections. Chosen actions have text markers, spent Assists say “used,” and energy costs are labeled.
- Name/seed dialogs consume travel and developer shortcuts. Enter activates the focused dialog button, including Cancel.
- Keyboard focus has a visible marker, survives redraws, and skips disabled controls.
- Camp navigation no longer overlaps the road log. Camp and shop actions reuse the resource icons, and disabled camp actions explain why.
- Disabled primary-button icons retain contrast. Companion art has more clearance above nearby controls and headings.
- The map labels reached/upcoming stops and does not mark the entire route reached after an early return.
- Travel estimates are labeled as base values because crew and conditions modify them.
- Foraging previews account for space freed by meals and show food found, food packed, and the actual net gain.

## Automated coverage and limits

`tools/test.ps1` runs seventeen Lua checks, including eighty seeded journeys across two strategies, plus native save/load and corruption-recovery checks. Twenty-five native GUI fixtures cover the major screens. Additional native interaction checks exercise battle readiness, selection clearing, modal shortcut isolation, text editing, focused Cancel, and focus persistence across redraws.

The user confirmed that physical F3 opens the developer screen. The desktop automation tool's injected key presses did not reach this Defold window, so the remaining keyboard routing was checked through the actual input handler in the native GUI harness. This does not establish compatibility with every keyboard layout or input method.

CI runs the native checks with Defold's headless engine; local checks use the release renderer. Headless checks do not validate pixels. This pass is not final art approval, an audio listening review, a long-term balance study, or validation of other platforms and window sizes.

## Automatic combat follow-up — October 30, 2026

PR #4 replaces new battles with prepared automatic encounters. The earlier manual-combat observations above remain a historical record. Current coverage is 29 Lua checks, 120 seeded journeys with checkpoint replays, 360 bounded combat cases, 5,760 matrix trials, 12 Python review checks, native persistence/input tests, and 27 GUI states. At 1280 by 720, new-player and expert playtests verified victory, position swapping, defensive/follow-up combinations, pause/step, quit/reopen, reserve preservation, and one-time withdrawal costs. A startup input race and deferred GUI node exhaustion were fixed with regression checks. Physical keyboard usability remains limited to the prior owner's F3 confirmation; injected key presses still do not reliably reach Defold. See [the illustrated report](../reviews/combat-1.html) and [exact combat rules](COMBAT_RULES.md).
