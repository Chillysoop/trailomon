# Map-led journey

2026-11-04 owner request: the game feels like a spreadsheet. Main screen needs destination nodes, branching paths, dramatic UI simplification/color/icons, detailed wagon and visible movement into encounters. This explicitly resumes map/UI/wagon art and animation work; unrelated creature overhaul remains deferred. No new approval or YES/NO page needed.

S40 / PR #53 replaces ordinary departure/travel/landmarks/events with ui/journey.lua + presentation/overworld.lua. Real six stops and two forks only. Branch node callbacks use original leave command. Resource strip and four compact party slots retain canonical colors, labels, costs and two separate health/energy bars. Full terrain report and scene prose remain accessible. Old menus and legacy combat remain compatible.

Original code-native pixel wagon shared with combat; no generator, new dependency, credential or spending. Open cart shows orchard cuttings; covered variant has canvas. Map geometry/motion are presentation-only. Step saves once, motion completes before choices open. Reduced motion snaps; focus/menu/save-error cases covered. Calm ~3.6s/day, brisk ~1.2s/day; gameplay pace/costs/RNG unchanged. New view has >2048 primitive nodes; consistent production/native/capture GUI capacity is4096.

Validation:174 Lua scenarios plus full native suite, focused real-render captures and callback/keyboard path/encounter checks. Fixed quaternion radians (not degrees), exact endpoints, departure follower clipping, brief-copy overlap and full-report return navigation. No physical-input/audio or blind-human-fun claim. S5/S10 remaining balance/reliability gaps unchanged. Docs:OVERWORLD.md; evidence:reviews/evidence/overworld-1/.

Hosted answers rechecked: no new submissions. collecting C1-C3 chat approval remains processed. Stable launcher already installed by PR52 and follows the next successful local bundle automatically; no new shortcut install needed.
