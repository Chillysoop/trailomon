# Player clarity pass

October 31, 2026. Owner-requested use of consistent icons and recognition colors.

- Added a shared recognition palette to the existing 27-symbol catalog; the same concepts keep their color across screens. Disabled and primary controls retain contrast overrides.
- Energy and Condition now have distinct colors, labels, numbers and matching sidebar meters. Three-companion captures include exhaustion and zero condition. No essential information depends on color alone.
- Depot distinguishes crew points from coins, says CAN HAUL, shows pack quantities/prices/load, and disables unaffordable/full-load purchases. Both displays and transactions read the same goods definitions.
- Combat setup separates Pressure from Cover; active combat separates Energy, Condition and next-exchange cost. Gathering, work items and all three guide pages inherit the catalog.

Validation: 90 Lua scenarios, palette contrast on normal and selected surfaces, pack accounting, native save/load and 36 GUI states, plus native buy/return/full-load/re-enable interactions passed. The actual release renderer produced these 12 inspected 1280x720 screens. The final preparation capture follows the last DRAFT-to-CAN HAUL wording change; remaining screens are unaffected by that text-only edit. Source manifests identify both capture inputs.

The native checks caught a Lua multiple-return bug in the new color helper; it was fixed and covered before delivery. No physical keyboard, audio or human pacing claims are made. This focused pass required no generated art or Computer Use. No new YES/NO page was created because the owner directly authorized these changes.
