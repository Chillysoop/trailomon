# Work items and the pre-equipment checkpoint

2026-10-31: owner said Proceed; hosted next-1 revision 42 also approved N9/N10/N11 with no notes. PR #24 completes N1 checkpoint + N7/S9 as one coherent gameplay batch. Queue new approved work after it; N6 art remains deferred. See next-steps.md for priority.

No base combat changes. 5,760 baseline scenarios at e5e5809 and no-item reruns match byte-for-byte. Multiple crews have useful contexts: Cindercoil/Slatewhorl is strong against the guardian, Reedskipper/Bellmoth takes less scavenger harm, default Brindlehorn/Loamling can win the guardian while retaining digging. Peaceful costs still matter. S5 remains doing for broader balance; checkpoint no longer blocks S9.

Implemented three items, one slot per companion and one of each per journey. Padded trace (12 coins/4 load): hurried base haul 11→8; first damaging approach hit -6 once. Rope (10/3): crossing food/cargo loss halved, not wagon/crew damage; participating wearer caps scavenger fallback/withdrawal at 4/4, no guardian-day benefit. Dry wrap (8/2): +3 fed rainy-day energy; Bellmoth rain shimmer stays 16. No drops/crafting/tiers. Inventory uses load even unequipped. Stop outside encounters to change assignments. Depot-only returns; supplies repacked each new trip, no profile item retention.

Optional save fields preserve older saves. Validation checks ownership, uniqueness, capacity, known IDs and spent armor. Native serialization covers actual gear and armor use. UI reuses semantic travel icons with item names/costs; no new art generated. Crew, depot and shop link to one equipment page; combat names equipped items and uses actual rope/Bellmoth descriptions.

Validation: 64 Lua, 3 capture-isolation, native persistence and existing 36 GUI states pass, plus new item/Enter interactions. 144 full reference journeys (seeds1–12 × 3 policies × 4 loadouts) repeat exactly. Trace/rope targeted benefits pass; dry wrap reduces recovery in these fixed strategies, not proof of optimal balance. Source hashes and compact results live in reviews/evidence/work-items-1. Seven relevant rendered views inspected; depot explanatory text overlapped new button, fixed and recaptured. An inherited fixture assertion was corrected for the crew view; no game crash occurred.

Physical keyboard, listening, human pacing and known native activation fault remain open for N8/S10 milestone. No Computer Use or paid art. Rebuild the Windows ZIP once at the clean merged gameplay head; builds/Trailomon-windows.json is authoritative provenance. Do not rebuild for later review-only edits.

Delivery: PR #24 merged as b14aef3ea539e940c397a26e7487b16d8812d171. The clean Windows ZIP built at that revision had SHA256 adf6161e441ca843a322961304f3df585f86277e6828e7460975880a9c9e3bcf. Later gameplay batches replace the ZIP; its sidecar is current provenance.
