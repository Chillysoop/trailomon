# Creature encounters

2026-10-31: wild-1 revision 7 approves W1–W6 with no notes. Deliver in small batches; no further design vote needed for these bounded options.

W1/W2 shipped in PR33: three once-per-run habitat sightings replace eligible ambient slots without entering/diluting the major pool. Consequential sightings obey the existing quiet-day cooldown; recruitment follow-ups retain priority. Older journeys with no wildlife_rules retain the original event selection. New journeys use wildlife-v1.

Guide separates Known, Seen wild and Traveled. Observation maps persist at an ending, including rescue/return, with new-observation count in results. Old profiles keep companions; unprovable historical observations/travel are not invented. Existing six wildlife encounter/recruit scenes also record sightings. No battle or numerical collection reward is required.

Validation: 94 Lua scenarios, 36 native GUI states and native save round trips; 36 new-rules reference journeys replay exactly. Historical combat/report golden comparisons retain their original event rules instead of replacing expected outcomes. Three actual 1280×720 captures inspected: sighting, species guide and run result.

W3/W4 shipped in PR34: Mara meets the wagon at Split Oak and recognizes help at Mossbell; end-of-run records preserve help/practice across trips. Optional practice is offered once per run at Mossbell. The opposing Brindlehorn/Bellmoth pair shares Resolve 45, with shove 14, heavy approach 18 plus cover 8, then heavy load 20. Practice load starts at 30; real energy is spent but condition/cargo/supplies/days stay unchanged. Setup remains freely reversible; skip/withdraw have no penalty. Practice counts as a combat exchange for the existing quiet-passage aim. Older journeys lack courier_rules and keep their route events.

W3/W4 validation: 98 Lua scenarios; all 30 ordered species pairs with save/forecast equivalence; 12 matched practice/skip continuations plus repeated practice runs; native persistence/GUI; four actual views inspected. Fixed unsupported text encoding and the old territorial sprite showing in practice. Python file edits must use explicit UTF-8 on this Windows machine.

W5 implemented: Options switches Classic/Discovery saves. Classic retains expedition_v1; Discovery uses discovery_v1; each has backup and depot_selection remembers selection. Failed saves block switching. First Discovery departure chooses one Brindlehorn/Reedskipper; optional Loamling/Bellmoth invitations at Split Oak/Mossbell cost 4 food. Recruits persist. The other starter has no Discovery acquisition scene in this slice; Classic retains both. Current art preserved.

W6 implemented: 3 well-fed working travel days unlock a depot-selected habit. Brindlehorn/Slatewhorl: haul energy -2, distance -4%; Reedskipper: assistance -4, dry-clear hauling +1; Loamling: gather energy -6, yield -2; Bellmoth/Cindercoil: road assistance -4, upkeep +0.5 before meal rounding. One optional tradeoff, no combat levels. Save validation, actual costs and previews share rules.

Final validation: 104 Lua scenarios, native save/backup/two-depot reopen, 36 GUI states and controller checks; focused rendered screenshots in reviews/evidence/discovery-habits. 64 full Discovery/habit runs (2 starters × 16 seeds × on/off) replayed exactly, no rescues/stalls. On-time deliveries: Brindlehorn 4→1, Reedskipper 6→5 with habit; others late. This reference policy does not optimize habits; broader S5 balance remains open. Fixed developer-menu overflow and Options/Crew overlap.
