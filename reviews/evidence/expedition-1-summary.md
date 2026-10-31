# Full-expedition report

Source: `81e700413575db9245ffd2470a15bd1eac45282c`; working tree changed: `False`.
Source/runtime fingerprint: `ae1b586716dcd4d7e6b9dc3942ba391d4c94e7004fd20b2fc66e776b2b6cf243`.
Exact repeat run: **PASS**. 120 full journeys; 339 matched continuation runs.

## Full-journey policies

| Policy | Runs | Delivered | Late | Rescued / returned | Failed | Median ending day | Recovery days |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| careful | 40 | 23 | 17 | 0 | 0 | 26 | 20 |
| peaceful | 40 | 14 | 26 | 0 | 0 | 27 | 31 |
| fighter | 40 | 5 | 35 | 0 | 0 | 28 | 65 |

## Matched alternatives versus peaceful resolution

| Event | Alternative | Matched starts | On-time gained | On-time lost | Median extra days | Median extra recovery days | Median cargo difference |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| scavengers | fight | 75 | 0 | 24 | 1 | 1 | -6.0 |
| scavengers | withdraw | 75 | 1 | 5 | 0 | 0 | -8 |
| territorial | fight | 38 | 1 | 2 | 0.0 | 1.0 | -8.0 |
| territorial | withdraw | 38 | 0 | 0 | 0.0 | 0.0 | 0.0 |

Positive extra days mean later arrival. Cargo differences are percentage points. Gained/lost counts compare on-time delivery within each matched pair. Only pairs with both branches completed are included.

## Reading the evidence

- Full-journey policies also choose different routes and events. Their delivery rates do not isolate the cost of combat.
- Matched branches clone the complete naturally reached encounter snapshot, including pending rolls and RNG streams. Only the current intervention changes; the subsequent policy is the same within each comparison.
- Comparisons are selected from encounters these policies actually reach with battle available. Starts may repeat across policies; these are not independent trials or a random sample of every crew. comparison_points records when a peaceful option is unavailable.
- Resource minima are sampled at command boundaries. Decreases/increases sum signed command deltas; they are not gross consumption inside a command. Gathering can spend meals and gain food in one action.
- Recovery counts cover rest, treatment, repair and river waiting. Event delays and combat detours remain visible under days_by_command and individual steps.
- Decision gates record entry into a mode needing input, including the starting mode. longest_travel_stretch counts consecutive travel-day commands. The headless bot does not measure human waiting, audio, usability, or the 20–35 minute playtime target.
- runs.csv contains summaries; comparisons.csv contains immediate encounter deltas and downstream results. Each runs/*.json file contains initial/final diagnostic snapshots, every command and argument, before/after resources, deltas, messages, minima, gates and failure context.

## Reproduce

```powershell
./tools/expedition_report.ps1 -Seeds "1:40" -Compare
./tools/expedition_report.ps1 -Replay "reports/<folder>/runs/<id>.json"
```

Replay requires the same source/runtime fingerprint and checks the complete recorded result. Diagnostic JSON snapshots are not player-save files; reproduction regenerates the state through the real commands.

