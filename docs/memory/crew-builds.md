# Six combat kits and practice

2026-11-01 S29: all six existing species have repeatable original kits, no universal types. Reedskipper redirects/interrupts, Loamling exposes, Slatewhorl shields. Three carried work items have bounded replacement-combat interactions and drawbacks. Details and evidence: docs/CREW_BUILDS.md.

F3 → Wagon ambush / new combat loans selectable crews and gear, with Guard/Rush/Open & punish presets. Mara's wagon drill at Mossbell uses actual travelers and carried equipment, preserves custom names, and charges 6 Energy each once at Start. Positive Condition required. Full temporary combat HP, practice wagon, one borrowed medicine and repair; no lasting health/cargo/wagon/supply/time changes or rewards. Swaps during setup only; practice cannot swap in absent species or unowned equipment. The first actual attack/skill marks the existing peaceful-journey aim as fought; setup does not. Old courier encounter saves still complete. Normal road combat remains unchanged until S30.

v1 resolver/content frozen separately so old sample clocks/effects replay identically. New samples use wagon-ambush-v2 in the existing separate checkpoint; practice lives inside run.wagon_practice, committing payment and progress atomically. Save failures pause, profiles/new journeys clear controller state. Future S30 must settle real resources once; do not charge per fast basic hit.

134 Lua scenarios; native saves/checkpoints/GUI; eight production renders. All 20 trios ×3 seeds terminate with exact replay. 144 same-opponent preset/gear runs replayed from tick37: guard preserves wagon; rush is quicker with18–34 integrity; control benefits from compatible gear. All trios win this easy sample: not evidence of full balance or fun. See committed comparison JSON/source hashes. Known S10 physical-input/audio/human-pacing/native activation gaps remain; no new claim to resolve them.

B1/B2 foundation applied; B4/B5/B6/B7 remain approved bounded follow-ons. Six species and six playable kits, 24 authored briefs, 276 unfilled index slots. S30 expedition integration is next; no repeat decision page needed.

2026-11-01 owner explicitly requested Astronarch-like combat visuals. Shared scene, overhead meters, local hits, selectable units, optional log and compact inspector implemented. Wagon visible behind front guard; original assets retained. No broad art/animation pass. Pure feedback/name regression and native selection/log-reset tests pass.
