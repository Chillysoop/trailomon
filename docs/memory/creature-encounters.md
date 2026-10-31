# Creature encounters

2026-10-31: wild-1 revision 7 approves W1–W6 with no notes. Deliver in small batches; no further design vote needed for these bounded options.

W1/W2 shipped in PR33: three once-per-run habitat sightings replace eligible ambient slots without entering/diluting the major pool. Consequential sightings obey the existing quiet-day cooldown; recruitment follow-ups retain priority. Older journeys with no wildlife_rules retain the original event selection. New journeys use wildlife-v1.

Guide separates Known, Seen wild and Traveled. Observation maps persist at an ending, including rescue/return, with new-observation count in results. Old profiles keep companions; unprovable historical observations/travel are not invented. Existing six wildlife encounter/recruit scenes also record sightings. No battle or numerical collection reward is required.

Validation: 94 Lua scenarios, 36 native GUI states and native save round trips; 36 new-rules reference journeys replay exactly. Historical combat/report golden comparisons retain their original event rules instead of replacing expected outcomes. Three actual 1280×720 captures inspected: sighting, species guide and run result.

W3/W4 implemented: Mara meets the wagon at Split Oak and recognizes help at Mossbell; end-of-run records preserve help/practice across trips. Optional practice is offered once per run at Mossbell. The opposing Brindlehorn/Bellmoth pair shares Resolve 45, with shove 14, heavy approach 18 plus cover 8, then heavy load 20. Practice load starts at 30; real energy is spent but condition/cargo/supplies/days stay unchanged. Setup remains freely reversible; skip/withdraw have no penalty. Practice counts as a combat exchange for the existing quiet-passage aim. Older journeys lack courier_rules and keep their route events.

W3/W4 validation: 98 Lua scenarios; all 30 ordered species pairs with save/forecast equivalence; 12 matched practice/skip continuations plus repeated practice runs; native persistence/GUI; four actual views inspected. Fixed unsupported text encoding and the old territorial sprite showing in practice. Python file edits must use explicit UTF-8 on this Windows machine.

W5 optional discovery profile and W6 depot habits remain approved follow-ups. Preserve normal profiles separately and existing art.
