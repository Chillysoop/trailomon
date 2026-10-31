# Expedition symbols

October 30, 2026. The owner's next-1 comment makes visible clarity and simplicity critical path. The system helps the player recognize a cost or role quickly; it does not replace the words needed to make a decision.

## One source of meaning

`ui/iconography.lua` owns each symbol's canonical label, short meaning, silhouette description, field-guide group, and species-role mapping. `ui/icons.lua` owns the authored 12 by 12 pixel drawing. `ui/widgets.lua` renders symbols and shared labeled readings. The journal's **Symbol guide** shows the same catalog in the game. A new resource does not get an unrelated stock symbol, a second meaning for an old symbol, or a local mapping inside one screen.

The catalog has three groups: supplies/time; crew/encounters; road actions/places. It currently covers 27 concepts. Provisions use a grain stalk; gathering uses a basket and shoot. Wagon condition uses the vehicle; hauling uses a yoke. Approach uses an arrow meeting a boundary; pressure uses the angular strike. These distinctions keep an action, its cost, and its result from looking interchangeable.

Energy is the player-facing name for the saved `stamina` field. Condition is health. Cargo is the living orchard delivery, while Load is packed weight relative to capacity. Cover reduces harm; an Ability is a triggered species action. Keep those names consistent when equipment or new duties arrive.

## Drawing and placement

- Author on the 12 by 12 grid using ink, accent, and negative space. Keep one strong silhouette; avoid small interior decoration.
- Draw at whole-pixel 12, 24, or 36 pixel sizes. The renderer centers nearby requested sizes on a whole-pixel grid. Use 24 for normal readings; reserve 12 for compact readings that already have adjacent text and values.
- Use the same mark in preparation, travel, encounters, shops, gathering, and the journal. A tint may reinforce a cost or a trigger, but a word, number, or state explains it independently of color.
- Pair every actionable mark with a visible label. Repeated status bars also retain written Energy/Condition values or adjacent labels. Do not add icon-only controls.
- Prioritize the decision. Three clear readings and an explanation are preferable to a wall of badges. Do not put a symbol on a sentence merely to fill space.

## Context and state

Combat readiness uses the actual resolver on a copied snapshot. It explains the pending exchange: triggers, spent, insufficient energy, needs care, wrong position, wrong target, waiting for a heavy rush, already covered, or repelled before the ability. Previewing cannot mutate the live state or saved RNG. The permanent ability description remains visible.

Combat results connect remaining Energy/Condition to an existing hauling, crossing (22 energy), or digging (18 energy) requirement. These messages introduce no new penalty. A gathering preview distinguishes food found, food that fits after meals, meals consumed, and expected net provisions. The journal records the actual result; the preview identifies shortage and closure limits.

## Adding a future feature

First write the player's decision and the distinction the new symbol must convey. Reuse an existing concept only when the meaning is genuinely the same. Otherwise add one original silhouette and metadata to the catalog, place it in the appropriate group, and use the shared renderer. Do not populate the game with icons for systems that do not exist yet.

Inspect the new mark beside every current symbol at its intended size, without color, and in a real decision screen. Check contrast, negative space, labels, and keyboard navigation. The catalog test rejects missing entries, duplicate drawings, malformed grids, and fractional pixel geometry. Native GUI checks cover all guide groups; rendered inspection is still required before accepting a mark.
