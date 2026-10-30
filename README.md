# Trailomon

A relaxed wagon expedition game about traveling with a small crew of original creatures. Prepare for the road, watch the journey unfold, and decide how to spend time, supplies, and your companions' energy when circumstances change.

The project is planned for **Defold**, using Lua for the simulation and 2D presentation. The initial delivery target is a Windows desktop prototype with mouse and keyboard controls.

## Design

The [game design document](docs/GAME_DESIGN.md) defines the core loop, creature systems, battles, replayability, persistent progression, and the first playable prototype. It also includes the proposed Defold architecture, implementation milestones, and acceptance criteria.

The current repository contains the design baseline. A runnable Defold project has not been implemented yet.

## First playable

One complete expedition from preparation to an ending, with a small creature crew, meaningful route choices, connected survival systems, short battles, local saving, and a reason to take a second trip. Prototype quantities and scope are maintained in the design document.

## Development order

Build the travel simulation and a complete route first, connect creatures and encounters next, then add persistence and presentation. Test whether the expedition is worth replaying before expanding the content or progression systems.
