# Trailomon

A relaxed wagon expedition game about traveling with a small crew of original creatures. Prepare for the road, watch the journey unfold, and decide how to spend time, supplies, and your companions' energy when circumstances change.

The first playable uses **Defold 1.13.2**, Lua, and 2D presentation. It runs offline on Windows with mouse and keyboard controls.

## Design

The [game design document](docs/GAME_DESIGN.md) defines the core loop, creature systems, battles, replayability, persistent progression, and the first playable prototype. It also includes the proposed Defold architecture, implementation milestones, and acceptance criteria.

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
```

The scripts download the pinned official Defold builder and verify its checksum. Testing runs deterministic Lua checks, native save/load recovery, and 25 GUI state checks in an isolated save namespace. `-SkipEngine` runs just the Lua checks. CI uses `-Headless` for machines without a graphics driver; local checks use the release renderer. Headless checks exercise screen construction and bounds but do not verify rendered pixels or human input.

The build script creates a fresh `dist/Windows-0.1.0-<timestamp>/Trailomon/` folder and a ZIP alongside it. Run `Trailomon.exe` with the four `game.*` files beside it. Release builds do not start the engine's development server. The scripts avoid replacing a running executable and work around OneDrive directory attributes by using fresh output folders.

## Project layout

- `simulation/` and `content/`: deterministic expedition rules and authored content.
- `ui/` and `presentation/`: screens, original pixel icons, and the wagon scene.
- `services/`: validated saves with backup recovery and the presentation clock.
- `tests/`: resource, event, combat, persistence, and repeatability checks.
- `assets/`: selected creature studies and original feedback sounds.

## Development order

Test whether the expedition is worth replaying before expanding the content or progression systems. Next priorities are human playtests, more distinctive creature anatomy and consistent side-view poses, frame animation, and clearer landmark scenery. Keep the scope and standing visual rules intact during those passes.
