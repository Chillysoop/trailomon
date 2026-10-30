# Creature sprites

These are selected draft studies for the first playable, made with Sprite Fusion. They are not final approved production designs. The [visual-direction guide](../../docs/VISUAL_DIRECTION.md) records the consistency and anatomy work still required.

Brindlehorn uses [study 1](../concepts/brindlehorn-generation.json) from the original concept batch. The other five species were made with `style-reference`, using that Brindlehorn asset as the visual reference. Each adjacent JSON record preserves the prompt, request ID, every returned output identity, and the selected output index. PNGs retain the chosen output without painted edits.

Selected indices: Reedskipper 0, Loamling 2, Bellmoth 0, Cindercoil 0, Slatewhorl 0. They were chosen after comparing the complete batches for a readable silhouette and a consistent earthy palette. Perspective, scale, anatomy, and role recognition still require a dedicated art pass.

The game uses a shared atlas with nearest-neighbor filtering. Idle and travel movement is procedural placeholder motion; this is not a completed set of frame animations. The terrain, wagon props, and interface icons are authored in code. The two feedback sounds are original synthesized tones.

`tools/sprite_fusion.py` is development-only tooling and takes authentication from `SPRITE_FUSION_API_KEY`. It does not run in the game. Credentials must never be stored in prompts, art records, or player builds.
