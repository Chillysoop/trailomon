# Trailomon

A relaxed wagon expedition game about traveling with a small crew of original creatures. Prepare for the road, watch the journey unfold, and decide how to spend time, supplies, and your companions' energy when circumstances change.

The first playable uses **Defold 1.13.2**, Lua, and 2D presentation. It runs offline on Windows with mouse and keyboard controls.

## Design

Start with the [current plan](docs/PLAN.md), [roadmap](docs/ROADMAP.md), and [project memory](docs/memory/MEMORY.md). The owner has selected one polished Windows expedition before additional regions. The [private plan review](https://trailomon-owner-reviews.dusky-owlet-9260.chatgpt.site/plan-1.html) works on a phone or computer after ChatGPT sign-in. [Review workflow instructions](reviews/README.md) include the desktop localhost fallback.

The [game design document](docs/GAME_DESIGN.md) defines the core loop, creature systems, battles, replayability, persistent progression, and the first playable prototype. It also includes the proposed Defold architecture, implementation milestones, and acceptance criteria.

The [world and lore proposal](docs/WORLD_LORE.md) develops the creatures, people, landmarks, and progression from maintained roads into poorly mapped wilderness. The [auto-battle and gathering proposal](docs/AUTO_BATTLES.md) records the reference study and future ideas. New encounters use [automatic combat](docs/COMBAT_RULES.md), led by Astronarch-style preparation and partner roles; Automon informs creature-party identity. Camp foraging remains deliberate, and older saved manual battles retain their original controls until completion.

The repository now includes a runnable Defold project. Open `game.project` in Defold 1.13.2 and build, or use the scripts below for a standalone Windows bundle.

The [visual-direction guide](docs/VISUAL_DIRECTION.md) and [persistent project rules](AGENTS.md) require intentional art direction and distinct, labeled iconography. [Creature art records](assets/sprites/README.md) document the selected Sprite Fusion studies and remaining art work.

## First playable

One complete expedition from preparation to an ending: six landmarks, two route choices, six creature species, eighteen authored event definitions, two optional battle scenarios, changing weather, fatigue and supplies, recruitment, local saving, and persistent companions and discoveries. A covered wagon unlock provides a different preparation choice.

Read the [playtest guide](docs/PLAYTEST.md) for controls, saves, and the current limitations. The art remains a selected concept pass with simple motion; final animation, richer scenery, and pacing need further playtesting and polish.

The [validation record](docs/VALIDATION.md) describes the completed Windows journey, fixes, automated coverage, and remaining testing limits.

## Build and test

Install Java 25 or use the JDK bundled with Defold. From PowerShell in this directory:

```powershell
./tools/test.ps1
./tools/build.ps1
./tools/expedition_report.ps1 -Compare
```

The scripts download the pinned official Defold builder and verify its checksum. Testing runs deterministic Lua checks, review/reporter integration checks, native save/load recovery, and 34 GUI state checks in an isolated save namespace. `-SkipEngine` skips native checks. CI uses `-Headless` for machines without a graphics driver; local checks use the release renderer. Headless checks exercise screen construction and bounds but do not verify rendered pixels or human input.

The build script creates a fresh `dist/Windows-0.1.0-<timestamp>/Trailomon/` folder and a ZIP alongside it. Run `Trailomon.exe` with the four `game.*` files beside it. Release builds do not start the engine's development server. The scripts avoid replacing a running executable and work around OneDrive directory attributes by using fresh output folders.

The latest shareable copy is `builds/Trailomon-windows.zip`. Each bundle includes controls, launch instructions, and `build-info.json` with its source commit and working-tree state. Python 3 is also required for review-server tests. Public release publication is a separate owner-approved step.

The [full-expedition report tool](docs/EXPEDITION_REPORTS.md) exports JSON traces, CSV comparisons and a readable summary under `reports/`. It repeats every run, checks source/runtime provenance, and can replay an individual trace. The default policies preserve the original test benchmarks; matched encounters compare fight, peaceful resolution and withdrawal before tuning game balance.

## Project layout

- `simulation/` and `content/`: deterministic expedition rules and authored content.
- `ui/` and `presentation/`: screens, original pixel icons, and the wagon scene.
- `services/`: validated saves with backup recovery and the presentation clock.
- `tests/`: resource, event, combat, persistence, and repeatability checks.
- `assets/`: selected creature studies and original feedback sounds.

## Development order

Test whether the expedition is worth replaying before expanding the content or progression systems. Next priorities are human playtests, more distinctive creature anatomy and consistent side-view poses, frame animation, and clearer landmark scenery. Keep the scope and standing visual rules intact during those passes.
