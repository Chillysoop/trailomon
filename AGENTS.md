# Persistent project rules

## Art and interface direction

These are standing user requirements, established October 30, 2026. Apply them from the beginning of every feature and art pass.

- Art and UI must avoid generic AI-generated aesthetics and template-like presentation. Make intentional choices about silhouette, palette, composition, hierarchy, spacing, and the game's pastoral travel identity. Do not treat the first generated output as finished art.
- Use one coherent visual language across creatures, scenery, interface, and effects. Inspect generated assets, reject unsuitable variants, and record remaining issues honestly. Sprite Fusion is an authorized development tool; generated assets still require selection and production review.
- Create distinct, consistent iconography as a functional visual aid from the start. Give recurring resources, creature roles, conditions, locations, and actions recognizable symbols. Pair icons with short labels and values; color or icons alone must not carry essential meaning.
- Reuse the same symbol for the same concept across preparation, travel, events, combat, and the journal. Avoid emoji, unrelated stock icon packs, ambiguous decorative symbols, and icon-only controls without accessible labels.
- Favor a readable expedition interface that belongs to this world. Avoid dashboard decoration, excessive cards or badges, generic gradients, and ornamental detail that competes with the journey or a decision.
- Verify the actual game at its intended window size. Check icon recognition, text contrast, clipping, spacing, and keyboard operation. A successful build is not evidence that the interface works visually.

## Technical direction

- Use Defold and Lua. Preserve the Oregon Trail expedition loop, the small creature crew, and the calm decision rhythm described in `docs/GAME_DESIGN.md`.
- Keep simulation state deterministic and separate from rendering. Do not use cosmetic randomness for game outcomes.
- Use `tools/test.ps1` for simulation and native persistence checks and `tools/build.ps1` for a Windows release bundle.
- Keep credentials out of repository files, art records, logs, and player builds.
