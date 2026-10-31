# Creature encounters

2026-10-31: wild-1 revision 7 approves W1–W6 with no notes. Deliver in small batches; no further design vote needed for these bounded options.

W1/W2 implemented: three once-per-run habitat sightings replace eligible ambient slots without entering/diluting the major pool. Consequential sightings obey the existing quiet-day cooldown; recruitment follow-ups retain priority. Older journeys with no wildlife_rules retain the original event selection. New journeys use wildlife-v1.

Guide separates Known, Seen wild and Traveled. Observation maps persist at an ending, including rescue/return, with new-observation count in results. Old profiles keep companions; unprovable historical observations/travel are not invented. Existing six wildlife encounter/recruit scenes also record sightings. No battle or numerical collection reward is required.

Validation: 94 Lua scenarios, 36 native GUI states and native save round trips; 36 new-rules reference journeys replay exactly. Historical combat/report golden comparisons retain their original event rules instead of replacing expected outcomes. Three actual 1280×720 captures inspected: sighting, species guide and run result.

W3/W4 courier, W5 optional discovery profile and W6 depot habits are approved, not implemented in the wildlife/guide batch. All retain current art and the small crew.
