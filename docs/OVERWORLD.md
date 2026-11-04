# The journey is the main screen

November 4, 2026. The owner described the game as feeling like a spreadsheet and requested a dramatic map/UI overhaul, a wagon matching the creatures, and visible movement into encounters. S40 implements that direction. This is an explicit exception to the earlier visual-work deferral, scoped to the journey and shared wagon.

## Playable changes

- Departure, travel, forks, river crossings and roadside encounters share an authored overhead route map. The six existing destinations are linked spatially; fields give way to woodland, river and high country.
- Split Oak offers the actual Meadow/Woodland routes; Cairn Gate offers Ridge/Gorge. Click the labeled branch on the map or select it with Tab/Enter. Distances, terrain, supplies and deadlines still come from existing expedition rules.
- Click a destination for its services and significance. Future stops are inspectable, not fast-travel buttons. Unchosen routes remain visible. There are no invented future encounter predictions.
- The wagon, hauler and companions travel together. A completed travel day is saved once, then its movement plays before encounter choices open. Encounters appear at the wagon's actual progress on its chosen road.
- The top strip uses the existing distinct resource symbols/colors. Four compact party positions retain explicit Energy/Condition readings and care warnings. Departure packing sits beside the map instead of a roster table.
- Cost, risk, deadline and shortage information stays visible. Brief encounter text accompanies choices; **Read the scene** reveals the full authored text. **Full report** retains detailed terrain/crew guidance at forks.
- The original wagon is drawn on a two-pixel grid with timber, iron straps, spoked wheels, a driver, lantern and orchard cuttings. The covered design has a separate canvas silhouette. The same prop appears in road and combat scenes.

## Timing and saves

Presentation only: calm playback is roughly 3.6 seconds per travel day, brisk roughly 1.2, including the wagon movement. This replaces the old 20/2.5-second static viewing waits; travel pace, event odds, resource costs, combat and expedition days do not change. Decisions still stop time. Reduced motion snaps directly to the saved position at the equivalent viewing interval.

Map geometry and temporary motion live in `presentation/`; they never consume simulation RNG or enter saves. Existing saves resume at their real location, paused as before. Menu navigation cancels the cosmetic remainder; focus loss suspends it; save errors stop automatic progress. No day or encounter replays after loading.

## Validation and review

174 simulation scenarios pass, including both forks, saved endpoint accuracy, motion/encounter gating, reduced motion and focus/menu/save-failure handling. Native release-renderer checks exercise departure buying/refunding, all four path selections with keyboard activation, free landmark inspection, movement to an encounter, reading its details, entering wagon combat and returning to the map. Existing native save/back-up/collection checks remain green. A fresh Windows bundle is delivered through the stable desktop shortcut.

Evidence in `reviews/evidence/overworld-1/` covers departure, four-person travel, two movement positions, wildlife, ambush choices, both forks, river and shared combat wagon. These are actual 1280x720 game renders, not mockups. Their source manifest records the tested inputs.

First-time-player lens: destination, daily food horizon and visible paths can be read without opening the old map page; a single Travel button advances the expedition. Expert lens: route distance/wear, crossing risk, recovery access, individual condition and food cost remain available. Fixed during verification: disconnected rotated path segments, followers crossing the screen edge at departure, overlapping encounter copy, and full-report navigation returning to the older travel view.

This was a focused interface/controls playtest, not a new blind participant test, listening review, or proof of human enjoyment. Existing deterministic full-expedition coverage was rerun; broader combat/food balance and physical-input reliability remain S5/S10. The secondary crew, collection, journal and camp reference screens retain their existing layouts. No new species, extra route branch, encounter rule, public release or art-service spending is included.
