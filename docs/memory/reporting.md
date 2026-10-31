# Expedition reporting

2026-10-30: Owner explicitly requested N1's full-expedition report tool. PR #10 implements S2; S5 balance is deliberately unchanged. Use `./tools/expedition_report.ps1 -Compare`, or `-Replay <run.json>`. See docs/EXPEDITION_REPORTS.md. Outputs under ignored reports/; no player-save access.

Frozen reference-v1 policies preserve the existing careful/peaceful/fighter bots. Default 40 seeds each. Matched branches copy naturally reached encounter state, then fight/first-available-peaceful/withdraw-before-first-exchange and use the same downstream policy. Missing peaceful options are recorded. This is not an exhaustive party or choice optimizer. Same starting states can occur under different policies; counts are not independent trials.

Baseline source: 81e700413575db9245ffd2470a15bd1eac45282c, clean tree. Source/runtime fingerprint ae1b586716dcd4d7e6b9dc3942ba391d4c94e7004fd20b2fc66e776b2b6cf243. 120 journeys + 339 continuations (113 sampled starts), all complete, every case repeated exactly. Careful 23/40, peaceful 14/40, fighter 5/40 delivered; median ending days 26/27/28. Scavenger fight versus peaceful: 75 matched starts, 0 deliveries gained, 24 lost, median +1 arrival day and +1 recovery day. Guardian: 38 starts, 1 gained, 2 lost, median +0 arrival days / +1 recovery day. Interpret within these reference crews/policies only.

Readable summary, CSVs, manifest and one replayable sample are committed under reviews/evidence/expedition-1-*. The existing owner-private next-1 review includes the findings with original codes and votes intact. Local complete traces are reports/n1-baseline/. The sample was replayed through the PowerShell launcher successfully.

Every action validates state; failures/stalls/budgets return context and a nonzero process exit. Batches repeat and compare every recorded value. Replay checks source/runtime and full trace. Text fingerprints normalize CRLF/LF; runtime hashes are byte-exact. Diagnostic JSON is not a native player-save format. Minima are command-boundary observations; spending/recovery within an action may cancel. Gates and travel ticks are not human playtime. Keep these limitations in any balance report.

40 Lua / 17 Python checks pass, plus native persistence and 34 GUI states. Original 120 journey end states are unchanged. Tests cover accounting, exact starts, stalled/no-action/mutating/throwing policies, bad commands, limits, bounded output, replay tampering and log rollover. A replay metadata bug found during implementation was fixed: full runs exported with comparisons must regenerate comparison_points too.

Next: N8 full-trip player validation, then evidence-led S5/N3 work. Normal game build and gameplay code are unchanged by the reporting tool.

The existing owner-private Site published the report successfully from source 3c90bdabd6a50fb5752db1f24728474277e2bd49; metadata retains the returned version. Isolated phone/dark and desktop/light browser checks covered votes, notes, FINISH, persisted JSON, no console errors, width, and all six evidence links. Review screenshots contain synthetic fixture votes, never owner answers. No new approval is required. Existing Windows ZIP still matches shipped gameplay.
