# Integration and player clarity

2026-11-02: owner requested fresh Pokemon / Astronarch / Oregon Trail analysis and UI clarity. docs/INTEGRATION_AUDIT.md audits main 4a486fe against primary references (MECC 1985 manual weighted most, 5th Edition secondary, Nintendo Red, developer Astronarch description).

The old identity percentages/combat-command shares describe pre-S30 rules; do not repeat them as current measurements. New combat already uses independent clocks, repeating skills, six kits, three items and persistent wagon/crew costs. Main gaps: full-crew invitations lose collection payoff, route reports lack learned enemy behavior, two road opponents share the raider/caller foundation. Six species implemented; 300 remains future target.

New integration-1 proposals I1 remembered Cindercoil invitation/depot rendezvous, I2 learned threat notes in existing reports, I3 distinct raider/guardian behavior tests. Recommended I1, already-approved S32, then I2/I3. I1 was superseded on 2026-11-02 by the owner's explicit four-active/uncapped-collection request (S37). I2/I3 remain unanswered. Existing A2/A3, D4/D5, E1/E2 remain on original pages; S32–S36 remain approved; B3 terrain creation remains rejected. No votes synthesized. Hosted submissions at start unchanged (bestiary9, journey5, next42, plan7, wild7).

Implemented clarity: Crew Road/Combat rows and equipped item; Abilities & story shows actual active/passive/repeating Focus cost plus HP/Energy relation. Legacy journeys retain matching encounter wording. Camp links to crew treatment without spending; Playback replaces ambiguous Speed/Travel view; due D26/closure D32 stays beside current day. No art, balance, save or engine-setting changes.

Validation: 154 Lua checks, native persistence/GUI including all six/legacy kit descriptions and no-cost care/playback, seven 1280x720 renders with production callbacks. Six-memory layout checked. New phone/desktop light/dark page plus isolated YES/NO/notes/FINISH/wait fixture pass; 21 review-server tests pass. Previous S10 journeys remain valid evidence because gameplay is unchanged; physical input/audio/real-time pacing/activation remain open.

Capture gotcha: an image preview appeared to omit unchanged sidebar content. Original and final PNG SHA256 were identical, and all sidebar pixels matched. No renderer fix was warranted; reverted all diagnostic engine/widget changes. Inspect full original pixels/hashes before chasing a preview artifact.

Last prior shareable build: 4a486fe (PR48), ZIP SHA256 1b3224b5510db26baf8ea61a14165a13384a27d615ad7b193c2cb110e5a267af. Current delivery provenance belongs in the local build record; fold into next substantive update.
