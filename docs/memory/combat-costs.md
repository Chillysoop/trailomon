# Bounded combat-cost pass

2026-10-31: Owner said continue after the next-priorities review. Hosted next-1 revision 37 reaffirmed all N1–N8 YES; N1 was explicitly toggled on again. No new approval needed. Complete one bounded N1/S5 pass, then move to N5/S7 wilderness and N6/S8 creature identity, not another tooling project.

New journeys use trail-effort-v2: ordinary energy 3, once-only ability 6, harmless guardian warning 1. Ordinary readiness still needs 3, abilities 9 before the exchange. Caps: scavengers 15 and guardian 16 per participant. Adopt the four-stage guardian as normal territorial behavior for new journeys. Pressure, harm, peaceful choices, duration caps and loot remain unchanged.

Old saves without an effort version keep 4/8 costs and original guardian behavior for the entire journey; explicit old experiments keep their pattern with old effort. Active battles save their own version. New expeditions get the new rules. Native serialization covers old and new boundaries, backed by original exact regressions retained as legacy cases.

Evidence: 54 Lua tests, 12 review checks, 3 capture-isolation checks, 6 reporting checks; native persistence and 36 GUI states pass. Six real 1280x720 affected screens captured in 6.41 seconds and inspected, including old setup and tired result. CLI callbacks exercise selection and all exchanges; no Computer Use, physical-input, listening or human pacing claim.

7,200 guardian scenarios repeated exactly. New rested and 16-energy crews both win 420/1200, mean cargo harm 9.33 and companion harm 5.93. Old tired random guardians won 0/1200; old authored prototype 40/1200 with companion harm 11.63. At 16 energy the default crew can win but ends exhausted and must rest or reassign hauling. New rules improve fatigue without removing its travel cost.

38 matched guardian starts: old rules 11 delivered/27 late, mean day 27.66 and recovery 1.39; new rules for the whole continuation 13 delivered/25 late, mean day 27.13 and recovery 1.08. This changes later battles too, not only the first guardian. All 120 new reference journeys repeat: careful 23/40, peaceful 14/40, fighter 6/40 versus old fighter 5/40. Frozen policies are not optimal play. S5 remains doing; full balance and next milestone's player pacing are open.

Reproduce with tools/guardian_report.ps1; compact committed evidence is reviews/evidence/combat-costs-1.json. Launch Lua-dependent PowerShell scripts sequentially: Initialize-TrailomonLua re-extracts the executable and concurrent initialization can hit a file lock. The sequential retry passed; no gameplay defect was involved.

Known native activation crash remains unresolved. Use release renderer locally; headless engine may open a firewall prompt. Package once at the merged gameplay head; authoritative provenance is builds/Trailomon-windows.json.

Review published privately at next-1#cost-pass, source 34d529c668746f9a5e9942d93863658680b21c1f. Isolated YES/NO/note/FINISH and saved JSON checks passed on phone/dark and desktop/light; original eight codes retained. No synthetic owner votes.
