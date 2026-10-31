# Full-expedition reports

N1 / S2 measures the actual deterministic expedition model without launching the UI, touching player saves, or changing game balance. Java 25 and Python 3 are required, as for the existing test scripts. The launcher verifies the pinned Defold builder and extracts its LuaJIT runtime.

```powershell
# 120 journeys: seeds 1–40, each under three frozen reference policies.
./tools/expedition_report.ps1

# Also fork naturally encountered threats into matched continuations.
./tools/expedition_report.ps1 -Compare

# Select a reproducible sample and a new output folder (spaces are supported).
./tools/expedition_report.ps1 -Seeds "1:10,1848" -Strategies "careful,fighter" -Compare -Output "reports/my comparison"

# Verify the complete command trace and outcome of one recorded run.
./tools/expedition_report.ps1 -Replay "reports/<folder>/runs/<id>.json"
```

Reports go to a new timestamped `reports/expedition-.../` folder by default. Existing output folders are rejected; evidence is never silently overwritten. `reports/` is ignored by Git. Commit a small, identified baseline to `reviews/evidence/` when useful, rather than every full trace.

## Files and guarantees

- `summary.md`: full-journey outcomes and matched alternatives, with interpretation limits and reproduction commands.
- `runs.csv`: every complete or failed run, resource lows, recovery, travel ticks, decision gates, and outcome.
- `comparisons.csv` (with `-Compare`): immediate encounter changes and downstream delivery/recovery results.
- `paired-summary.csv`: fight/withdraw versus peaceful resolution from the same starts. Positive extra days mean later arrival; cargo differences are percentage points. Only completed pairs are included.
- `runs/<id>.json`: every command and argument, policy reason, before/after observations, resource deltas, newly added journal entries, resource minima, input-mode gates, initial/final diagnostic snapshots, and any failure context. Journal additions survive the game's 70-entry display limit.
- `manifest.json`: source commit, dirty-tree flag, hashes of simulation/content/reporter sources and the actual Lua runtime, options, completion state, repeat verification, and tool execution time.

Every batch is executed twice and compared in full. The source/runtime fingerprint must stay fixed during reporting. Text hashes normalize CRLF/LF so an equivalent Windows checkout can replay the report; runtime hashes use exact bytes. Replay regenerates the selected journey/encounter from its seed and policy, checks that fingerprint, and compares the complete result. Changing the trace or source is detected. JSON snapshots are diagnostic output, **not Defold player-save files**; regenerate through the commands to preserve Lua's native key types.

Run IDs distinguish full journeys from continuations. The JSON `reproduce` record identifies the input seed, policy and, for a comparison, encounter index and method. Initial and final snapshots include RNG state and the pending event roll. No cosmetic randomness is used.

## Policies and matched comparisons

The versioned `reference-v1` policies preserve the original test bots. They start with Moss and Buttons, standard supplies, steady pace and normal rations. They gather when food is low and the preview has positive net yield, repair below 28 wagon condition, and rest when the hauler is unavailable or below 18 energy. They buy food at Mossbell and use the ferry when affordable.

`careful` takes the meadow branch and the first available event choice. `peaceful` takes woodland and excludes battle choices. `fighter` takes woodland and prefers available battles. All use the ridge and the first two ready combatants. They are reproducible benchmarks, not optimal players. Their different routes mean that comparing aggregate delivery rates does not isolate combat's effect.

With `-Compare`, each naturally reached event with an available battle yields a copied starting snapshot. Branches fight, choose the first available peaceful option, or enter battle selection and withdraw before the first exchange. Each then follows the **same original downstream policy**. A peaceful branch is omitted if unavailable; the parent run's `comparison_points` explains the omission. This is not an exhaustive comparison of every peaceful ability, crew pairing, or possible retreat time.

Comparisons can share identical starts across policies. Counts are not independent statistical trials. Weather and later events may diverge because an intervention changes time or RNG use; that is a downstream effect within this model, not a reroll of the starting encounter.

## Interpret the measurements

Resource minima are sampled at command boundaries. Food/energy decreases sum negative command deltas and increases sum positive deltas; internal spending and recovery can cancel within one command. Do not describe these as gross consumption. Individual steps retain each companion's energy and condition and distinguish recruitment from gains on existing crew.

Recovery counts cover rest, treatment, repair and river waiting. Other delays appear in `days_by_command`, immediate encounter deltas, and the trace. Input-mode gates record where play needs a decision; `longest_travel_stretch` counts uninterrupted travel-day commands. None of these measures human waiting, visual clarity, audio, or the 20–35 minute playtime target. Tool execution seconds describe computer performance only. N8's full playtest and S5 balance work remain separate.

## Failures

The runner validates state after every accepted command. Rejected commands, policy exceptions/mutation, invalid states, repeated states, and the action budget produce explicit failure records, not a successful-looking journey. Repetition ignores journal prose so logging cannot hide a loop. The default guard allows 250 actions and at most three visits to the same state; override with `-MaxActions` and `-StallVisits` for a diagnosed case. Finishing on the final allowed action counts as success.

The command exits nonzero on a failed run, a mismatch, or an execution error. Inspect `manifest.json` and the affected trace before classifying a policy error as a game bug. To exercise the budget diagnostic intentionally: `./tools/expedition_report.ps1 -Seeds 1 -Strategies careful -MaxActions 1`.

`./tools/test.ps1` covers all 120 unchanged reference journeys, exact matched starts, accounting, JSON encoding, failure cases, trace replay, provenance rejection, and output preservation, alongside the existing native checks.
