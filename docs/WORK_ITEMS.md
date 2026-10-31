# Work-item experiment

Implemented October 31, 2026 under P5 / N7 / S9. Buy at Fernwake or Mossbell, then open **Crew → Work items**. The depot and shop also link directly to the same screen. Choose a companion, buy an object, and equip it. One copy of each object per expedition; one slot per companion. Moving an object transfers it rather than copying it. Unequipped objects still occupy load.

| Object | Coins / load | Travel | Automatic combat |
| --- | --- | --- | --- |
| Padded trace | 12 / 4 | Hurried hauling costs 8 instead of 11 base energy; readiness and forecasts use the same threshold | When worn at the approach, reduces the first hit that would still cause harm by up to 6. One use per encounter; spent state survives reload. It is padding, not partner cover, so it cannot trigger Cindercoil |
| Release rope | 10 / 3 | Halves food and cargo damage from a bad river crossing, rounded up for food. Does not lower the accident probability or prevent crew/wagon harm | A participating wearer halves scavenger retreat/fallback losses to at most 4 food and 4 cargo. Before a team is chosen, any equipped wearer can secure withdrawal. It does not remove the guardian's one-day detour |
| Dry wrap | 8 / 2 | With enough food, the wearer recovers 3 extra energy on rainy days, capped at 100 | Bellmoth's heavy-rush shimmer keeps its normal 16 cover in rain instead of 8. Other species do not gain a new ability |

Swap freely in preparation, at a landmark, or while stopped outside an encounter. Moving and encounter states reject swaps, including setup and the result screen. No mid-battle shopping, duplication, crafting, random drops or item tiers. Full-price returns are available at the depot before departure; returning an equipped object clears its assignment. Pack supplies and objects afresh for each expedition. Companions remain in the roster without retaining an item or permanent stat increase.

Older saves need no migration: missing inventory and assignment fields mean no item. Existing active battles continue unchanged. Validation rejects unknown items, duplicate assignments, unowned equipment, over-capacity purchases and invalid spent-item records. An item stays packed after a battle; padding refreshes only when a new encounter starts.

## N1 checkpoint before equipment

The unmodified baseline at `e5e5809e89f5dd751b7d630c6ada6afa57e30a7f` covered 5,760 cases: both encounter types, meadow/clear and ridge/rain, 100/16 energy, all ordered pairs and solos, seeds 1–20. Re-running without items after implementation produced byte-identical CSV. No base combat buff was justified by this checkpoint.

Examples at 100 energy in meadow/clear (20 seeds each):

| Crew: approach / wagon | Scavenger mean cargo / crew harm | Guardian wins / mean cargo / crew harm |
| --- | --- | --- |
| Brindlehorn / Loamling | 5.1 / 4.9 | 20 / 0 / 6 |
| Cindercoil / Slatewhorl | 7.2 / 4.8 | 20 / 0 / 0 |
| Reedskipper / Bellmoth | 2.7 / 3.3 | 0 / 14 / 0 |

The guardian specialist is not the safest scavenger pairing. Loamling also supplies gathering; Reedskipper can peacefully move the guardian for 18 energy. Paying 6 food avoids scavenger harm and fatigue; waiting one day avoids a guardian fight at the cost of meals/time. A prepared fight can save a day or food, but victory is not free. These comparisons establish roles and costs, not a universal ranking or optimal policy. Broader S5 balance remains open.

## Validation and limits

64 Lua scenarios pass, including eight equipment scenarios. Native save/reload preserves inventory, assignments and spent padding; native GUI interactions cover buying, moving, returning, navigation and Enter activation. Existing 36 GUI states and persistence checks pass. Seven changed screens were captured through the production renderer; a depot text overlap was fixed and recaptured. No new physical-input, audio or human-pacing claim.

144 complete fixed-policy journeys (12 seeds × 3 policies × no item/each item) repeated exactly without stalls or invalid saves. Dry wrap reduced recovery days in this sample; the trace's hurried-hauling benefit and rope's bad-crossing/retreat benefit are covered by targeted scenarios. None of these fixed-policy results proves final balance. All three items have competing slot, coin and load costs; buying none remains viable.

Run `./tools/test.ps1 -Suite Game`, then `.tools/luajit-64.exe tests/equipment_journeys.lua` for the compact journey comparison. The normal test script initializes the pinned LuaJIT if needed. Review evidence is in `reviews/evidence/work-items-1/`. Art is intentionally reused. N9 trail reports, N10 event chains and N11 optional journal aims are approved next work; they are not part of this item experiment.
