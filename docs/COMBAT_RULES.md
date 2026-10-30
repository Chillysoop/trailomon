# Automatic encounter rules

October 30, 2026. Implements approved P1. Astronarch is the primary influence for combat preparation, positions, roles, and partner interactions. Automon informs creature-party appeal. The expedition remains the main game.

## Preparation and timing

Choose one or two companions with positive condition and at least 4 energy. Selection order places the first at the approach and the second by the wagon; Swap positions reverses them. A third companion stays in reserve without costs, bonuses, or battle memories. A lone companion occupies the approach.

New encounters advance every five seconds at calm speed or 1.5 seconds at brisk speed. Pause, Space, and Step exchange offer control without reaction requirements. Opening a menu, losing focus, or loading a save pauses combat; returning requires Resume. Simulation advances only at exchange boundaries. Withdrawal acts at the current boundary before the next unresolved exchange. Speed and frame rate do not enter the rules.

The approach uses the species' ordinary pressure. The wagon uses half that pressure, rounded down, and provides 6 temporary cover to cargo and the approach. Either ordinary action costs 4 energy. An exhausted but conscious creature applies at most 1 cover to its own position's target, with no pressure or cost; an incapacitated creature does nothing.

## Abilities

Each ability costs 8 additional energy, once per encounter, when its condition actually occurs. Ordinary effort is paid first, so a creature normally needs 12 energy for an action plus ability. No ability is spent after ordinary pressure has already repelled the threat. Cover expires after the exchange.

| Creature | Trigger and effect |
| --- | --- |
| Brindlehorn | First rush with remaining harm toward cargo or its partner: 14 cover against that hit. Does not brace a hit aimed at itself. |
| Reedskipper | First rush with remaining harm: reduce harm by 10 and add 4 pressure. |
| Loamling | First rush with remaining harm: give all active targets 8 cover on soft ground; only 4 on ridge or gorge rock. |
| Bellmoth | First heavy rush with remaining harm: reduce harm by 16, or 8 in rain. |
| Cindercoil | If a partner contributed cover and the incoming hit is fully blocked: add 20 pressure. |
| Slatewhorl | From the wagon position only, first cargo rush with remaining harm: add 18 cover. |

Resolve ordinary actions together, then defensive abilities in position order, then Cindercoil's follow-up, then threat resolve and incoming harm. No recursive triggers. A fully repelled threat cannot deliver its last hit. The journal records the creatures' actions, cover, pressure, and actual harm. Initial condition, stamina, ground, and weather are visible; there are no undisclosed relationship multipliers.

## Threats and expedition costs

Both threats target cargo (55%) or the approach (45%) using the saved combat RNG stream. Every second exchange is a heavy rush, telegraphed before resolution. Normal harm is 12 for scavengers and 14 for the guardian; heavy harm adds 6.

Scavengers begin at 65 resolve. Repel them or hold for three exchanges with a crew still capable of acting. The territorial guardian begins at 75 resolve and must be repelled within four exchanges. If nobody can perform an ordinary action, retreat unless the threat has already been repelled. Encounters cannot stall indefinitely.

A retreat or unsuccessful defense leaves up to 8 food and 8 cargo integrity to scavengers, or takes a one-day territorial detour including ordinary meals and weather. There is no victory XP, money, equipment, capture, or meat. The result screen shows actual net food, cargo, days, energy, and condition changes, including detour recovery. Acknowledging it has no additional cost. Peaceful event choices remain available before committing.

## Save compatibility and verification

New battle records carry `rules="automatic-v1"`, ordered participants, initial resources, used abilities, pending intent, exchange history, and the saved combat RNG. Completed encounter reports persist until acknowledged. Untagged older battles use the preserved manual resolver and interface until that one encounter ends. They are not silently converted or reset. Unknown rule versions fail validation.

Run `./tools/test.ps1` for Lua and real-renderer native checks; CI uses `-Headless`. For an isolated playable encounter, use `./tools/test.ps1 -Fixture scavengers` (or `territorial`, `legacy`) and launch the release game with the namespace argument printed by the command. This keeps the owner's normal save untouched. Headless engines may trigger Windows network prompts locally; use the release renderer for local fixtures.

Run `.tools/luajit-64.exe tests/combat_matrix.lua` to emit deterministic CSV for all ordered pairs and single creatures across two scenarios, two conditions, two starting-energy levels, and twenty seeds. The committed evidence is a balance baseline, not a claim of final tuning. Distinct action animation, broader threat behavior, and equipment remain later work.
