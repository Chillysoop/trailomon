# Trailomon — integration roadmap

Updated November 4, 2026. **Phase: core systems integration.** One polished Windows expedition remains the milestone. Read [PLAN](PLAN.md) and [INTEGRATION_BLUEPRINT](INTEGRATION_BLUEPRINT.md) first.

This is a new work order, not a renumbering or deletion of earlier commitments. [The full prior roadmap](archive/ROADMAP-2026-11-04.md) preserves S1–S40, approvals and shipped PRs. New steps begin at S41. Existing S5/S10 remain open integration/balance responsibilities. The November 4 request changes combat from a side activity into a central expedition tension.

## Baseline and active work

- Shipped: map-led expedition/animated wagon (S40, PR53); four-member collection/Commons (S37–S38); wagon combat/gear/practice (S28–S30); deterministic tests, persistence, captures, reports and auto-following desktop launcher.
- Six implemented species; three implemented work items; no shipped battle levels, rest-stop exchange or component wagon model.
- Fresh baseline playthrough complete: Discovery 1848, day26 delivery, cargo80, food0, four companions, one lost battle. Evidence is linked in PLAN.
- Unreleased work is preserved on `codex/expedition-rpg` at `874cb5d`. Do not merge wholesale: simulation experiment only, UI incomplete. Start from current main and port reviewed pieces per step.
- This planning delivery adds no player build and does not mark gameplay steps done.

## Phase 1 — readable journey and combat foundation

| ID | Goal and dependency | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S41 | Fix map arrival and contextual help; next implementation | Wagon stays anchored when a panel opens; no duplicate travel payment or redundant encounter entry; costs/warnings remain visible; shared underlined keyword help works with hover, focus and click; direct return to map | Motion/save/focus/reduced-motion scenarios; actual departure→event→resolution captures; keyboard help and clipping checks | todo |
| S42 | Zone combat and readable preparation; after S41 | Two zones of 2×2 slots per side with four active; zone/front/nearest targeting; visible target lines and wagon exposure; click-to-place/swaps; distinct ordinary/override targets; old fights retain rules | Zone versus front precedence, retarget/KO/lure, exposed wagon, deterministic replay, native old/new saves; real setup/fight/result captures | todo |

**Playable checkpoint A:** an existing party can approach a threat, understand the formation, fight and return to its actual map location. Keep current resources/items while proving this.

## Phase 2 — collect, grow, recover and build a team

| ID | Goal and dependency | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S43 | Individual growth and recovery loop; after S42 | Qualifying battle XP settles once by individual ID; level changes battle stats without healing; marked stops heal/revive; reserve exchange preserves wounds/identity/gear and a hauler; quotes preserve exploration time | Duplicate species, KO eligibility, result/reload idempotence, early return, store/retrieve exploit, last-hauler rejection, native migration; battle→level→stop→exchange rendered sequence | todo |
| S44 | Sheets, species sockets and complete implemented-item catalogue; after S43 | Active and reserve individuals share a readable sheet; active/passive/field use separated; species combat/utility sockets; old item migration; roughly9–12 meaningful new items plus existing3; consumables included; discovery/source/ownership/compatibility clear | Slot/ownership/weight/effect scenarios; each item's actual trigger; catalogue read purity and large-list navigation; native gear saves; focused sheet/catalogue/shop views | todo |
| S45 | Authored threats, rewards and discovery along the actual route; after S42–S44 | Known threats/services visible on map; fair solo opening and escalating varied compositions; XP/gear/discovery from real encounters; alternatives retain explicit costs; no duplicate encounter farming | Fixed-seed solo/team and peaceful/fighter runs; same RNG/save outcomes; full novice/expert rendered journeys; report battle opportunities, choices, care, exploration and delivery | todo |

**Playable checkpoint B:** collect → sheet → equip → formation → XP/injury → care/exchange → new route decision works without developer shortcuts. Rebuild the Windows player here after tests/CI. Do not add new regions or dozens of species to compensate for weak connections.

## Phase 3 — wagon and cargo depth, selected through review

G1/G2 on [integration-2](../reviews/integration-2.html) are new unanswered design refinements. Their implementation is conditional; they do not block S41–S45.

| ID | Goal and dependency | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S46 | G1 functional wagon parts; after YES G1 and checkpointB | Running gear/frame/cover with explicit causes/effects; one roadworthy HUD summary; visible damage locations; field/service repair preview; breakdown exit; old journey/battle compatibility | Damage/repair accounting, derived limits, no double hits/costs, zero-supply breakdown, migration; wagon/repair and battle→travel captures | todo |
| S47 | G2 protected loads; after YES G2 and checkpointB | Two protected positions plus exposed rack within one load budget; meaningful grouped loads; preview which cargo is threatened; visible delivery; no duplicate ownership or Tetris | Move/weight/ownership invariants, named hazards, cover/gear interaction, full hold/discovery, old saves; wagon packing→weather/raid→receipt sequence | todo |

If G1/G2 are rejected, record rejection and cut that step rather than relabeling it as approved. Complete relevant visual explanation with current underlying resources.

## Phase 4 — integrated balance, content and polish

| ID | Goal and dependency | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S48 | Whole-loop acceptance and old-system cleanup; after S45 and selected wagon work | Two viable builds; exploration fits delivery; no universal item/tank or swap/heal/XP exploit; coherent help/navigation; stale new-player combat/menu copy removed; compatibility retained | Fixed-seed team/route matrix plus full new-player and expert runs; old/new native saves; actual1280×720/grayscale/reduced-motion; physical input/audio limits reported honestly | todo |
| S5 | Balance combat against expedition needs; carried forward | Use integrated evidence to settle XP/care/encounter/load values; preserve purposeful peaceful/exploration choices | S48 evidence with battle time, recovery days, supply lows, exploration and outcomes | doing |
| S10 | Finish sound/settings/interface reliability; carried forward | Keyboard/focus/save/audio basics verified on the integrated build; clarity contract met | Native automation plus actual input/listening evidence where required | doing |
| S32 | Approved B4 symbiotic pair | One bounded pair reuses settled kit/slot/KO rules | Original approved deterministic/save/KO tests and actual UI | todo |
| S33 | Approved B5 learned local trick | Existing habit/field adaptation connection; no competing progression tree | Unlock/tradeoff/save/clarity checks | todo |
| S34 | Approved B6 food-web slice | One ecological encounter/trade uses existing event/cargo/collection boundaries | Costs/rewards/replay and readable consequence | todo |
| S35 | Approved B7 migration sample | Habitat/weather opportunity changes route/collecting choices without another deadline meter | Seed/eligibility/clue and full-trip impact | todo |
| S36 | Continue toward300 species | Author batches against final species schema; planned versus implemented counts explicit; implement only tested distinct kits | Editorial ecology/overlap checks, schema, kit/item interactions and save/render evidence | todo |
| S8 | Owner-led creature art overhaul | Deferred until owner resumes; required legibility fixes remain in normal work | Original silhouette/palette/scale review | todo |

## Phase 5 — release readiness

| ID | Goal | Done means | Validation | Status |
| --- | --- | --- | --- | --- |
| S12 | Shareable Windows candidate | Versioned ZIP, launch README, exact revision, no credentials/test saves; installed shortcut follows successful build | Clean extraction/start, old/new save roundtrip, CI, known limits | todo |
| S13 | Owner-authorized public release | Explicit publication authorization and matching candidate | Download/hash/start verification | todo |

## Delivery rules

One step or coherent bounded slice per `codex/` branch/PR. If a step is too large, append child identifiers such as S44a/S44b; never renumber published IDs. Test and self-merge once CI is green. Each PR includes relevant status/memory and rendered evidence for changed screens. Do not call an unimplemented plan, a passing simulation, or an experimental branch a completed feature.

At each checkpoint, assess the plan rather than blindly starting the next row. Reuse unchanged test evidence, run affected fixtures, and reserve full journey/balance/build work for the checkpoints. No new YES/NO page for already-approved work. Only genuinely open decisions receive controls.

Local PC review is now the default. Start/reuse this repository's review server, read answers before work/closeout, and wait for FINISH while the session is active. Check already-published hosted submissions for late answers, but do not republish new reviews to Sites unless requested.
