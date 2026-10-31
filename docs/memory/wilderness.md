# Wilderness presentation

2026-10-31: Continued approved N5/P3/S7 after PR #20 combat tuning. Hosted next-1 revision 38 reaffirmed N1–N8 YES, with the existing iconography/clarity note unchanged. No additional decision or paid generation was needed.

Six authored landmark treatments: nursery rows and graft ties at Fernwake; two living trunks at Split Oak; provision porch, wheel rim and bell at Mossbell; ferry and old water marks at Willowford; low shelter between cairns at the high-road commitment; a few warm windows and empty orchard terraces at Lantern Reach. Ordinary stretches use the chosen woodland/meadow and ridge/gorge route. Wheel ruts thin out, buildings disappear and horizons open farther along the route. Six existing landmarks only; no simulation or save-schema change.

Landmark choices now include a 180-pixel scenery strip and short place-specific text. Mossbell is labeled LAST SUPPLY SHOP and Cairn Gate LAST SHELTER; the map repeats those distinctions using the existing provisions/rest symbols with labels. The four-option river layout fits at 1280x720. The road distance label has a dark backing for contrast. Functional icons remain in the shared catalog; scenery does not introduce a second symbol set.

The scenery is authored native pixel geometry, not newly generated art. It remains intentionally simple; selected creature art still needs S8 anatomy/pose refinement. Do not call the whole game's art finished. Next is N6/S8 silhouette/scale comparison; existing assets first, paid generation only with spending authorization.

Verification: 56 Lua tests and 3 capture-isolation tests pass; native persistence and 36 GUI states plus keyboard-routing/interaction checks pass. New tests cover place selection, branch identity, delivery vs return and clipped drawing without state/RNG mutation. Real production GUI captures cover all six locations, both final branches, map, rainy river and combat (11 screens in 5.63 seconds). Production branch buttons were exercised. Seven unaffected images were byte-identical after the final renderer optimization; the changed travel/gate captures were re-inspected. No fresh full human journey, physical input, listening or balance matrix was warranted for this presentation pass.

Found/fixed during checks: extra hill rectangles exceeded Defold's deferred node budget during rapid redraws. Coalesced adjacent equal-height hill spans, preserving exact pixels and keeping the existing native interaction checks green; did not raise the node cap or relax tests. Known unrelated native activation crash remains open.

Reproduce: tools/capture.ps1 -Scenes route_depot,route_oak,route_outpost,route_river,route_gate,route_ridge,route_gorge,route_reach,route_map,route_rain,guardian_warning. Evidence and source hashes are in reviews/evidence/wilderness-1/. The next-1 page retains the original YES/NO codes and submitted votes.

Additional meadow/woodland captures exercised both Split Oak buttons and were inspected; 13 distinct views total. Private review source 19c16f3c525d1ab6d1754ff6fcabf4d9bf06b44d deployed successfully. Isolated phone/dark and desktop/light YES/NO/note/FINISH, JSON, image and overflow checks passed. Synthetic answers never touched the owner page.

Delivery: PR #21. Rebuild the Windows ZIP once from its clean merged head; builds/Trailomon-windows.json records authoritative provenance.
