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

## Owner and project workflow

The owner designs and steers; the developer plans, builds, tests, and ships. Current scope: one polished expedition first, Windows only, working title Trailomon. Follow `docs/PLAN.md` and `docs/ROADMAP.md`; use the lore and automatic-combat documents as proposals, not permission to implement every future idea.

- At session start, fetch latest `main`; work on a `codex/` branch based on it, never directly on `main`. Preserve other sessions' uncommitted changes. Read this file, `docs/memory/MEMORY.md`, the roadmap, and **every** file in `reviews/responses/` before choosing work.
- Start or verify the review server. Reuse port 8765 only when `/api/health` identifies this repository; never stop an unrelated service. Check late answers before asking about a page, saying work is waiting, omitting an idea, or closing a batch.
- YES means build as described and adjusted by the comment. NO means reject and record it so it is not proposed again. A comment wins over the original text; a comment without a vote still needs attention. Chat answers with idea codes count. After FINISH, blank ideas remain unbuilt; mention them once without nagging. Track acted-on answers in memory so repeated reads do not duplicate work.
- Use a review page for brainstorms, reports, balance, roadmap changes, option questions, or decisions needing more than about fifteen lines. Guided initial setup may use short chat questions. Give every proposal a stable code, explanation, evidence, cost, and recommendation; mark three to six top picks. Never renumber published codes.
- Every review has general comments, YES/NO toggles and notes per idea, an accessible sticky tally, top-picks button, save status, FINISH, autosave, phone layout, and light/dark support. Browser-test a separate fixture before publishing; never put synthetic votes in a real owner page.
- FINISH saves `reviews/responses/<page>.json` and a `.finished` flag. Start `py tools/review_server.py --wait <page> --timeout 540` and keep the active session waiting while doing independent work. Use short tool polls so chat remains responsive. On timeout code 2, re-run for up to roughly one hour; then state that the page remains open and recheck next session. FINISH cannot wake an already-ended agent session. Offline pages retain browser state, download JSON, and attempt clipboard copy for pasting.
- Ship each small step or coherent approved batch as a PR with what, why/step or idea code, validation, and evidence for visible changes. Attach every created PR to this chat. Run relevant tests and play visible game changes before opening; fix CI failures without weakening checks. **Merge tested PRs yourself; owner PR approval is not required.** Ask first only for large deletion/history removal, changes outside this repo, public release publication, or spending money. Existing authorization for a specific action remains valid.
- After a merge, update roadmap and memory and rebuild likely-to-be-shared Windows changes. Build locally without publishing a GitHub release unless expressly approved.
- On "what's next" or a phase boundary, inspect the game against the plan, including saves, settings, audio, bugs, and tests. Publish a review with the actual phase, completed work, real gaps, and five to twelve options with top picks.

## Tests and playtests

Keep deterministic system scenarios, save checks, and native UI checks green. Add meaningful regression coverage for fixes. Use full-run bot results to find stalls, resource failures, and pacing outliers; report the seeds, strategy, and source revision. A headless build verifies construction and logic, not rendered appearance or physical input.

After a large batch or a requested playtest, drive the actual game in both new-player and expert roles. Capture key screens, report confusion and exploitable strategies with evidence, and publish a review page. Fix obvious bugs in a tested PR immediately; ask about design changes. Reports state verdict, what worked, findings/evidence, already-fixed bugs, and coded proposals.

## Memory and communication

Keep `docs/memory/MEMORY.md` as a one-line-per-file index. Use subject files under about 4 KB, update existing notes, use absolute dates, and record decisions/reasons, rejected ideas, answer processing, setup, known issues, and gotchas in the same session. Do not duplicate code or git history.

Keep chat short and plain. Lead with the result or decision and its link. Do reversible authorized work without asking again. Explain exact blockers. End a completed batch with the single most useful next step. No new delegation or subagents unless the owner explicitly requests them.

## Commands and delivery

- Run the game: `./tools/build.ps1`, then launch the executable path it prints. A Defold editor can also open `game.project`.
- Tests: `./tools/test.ps1`; `-Headless` for CI; `-SkipEngine` for Lua simulation only.
- Review-server tests: `py -m unittest discover -s tests -p "test_review*.py"`.
- Review server: `py tools/review_server.py` at `http://localhost:8765/`; start hidden in the background on Windows. It uses Python's standard library only. `--wait PAGE --timeout 540` prints a finished answer snapshot and consumes the flag.
- Windows bundle: `./tools/build.ps1`. Keep timestamped working bundles in `dist/` and the shareable archive at `builds/Trailomon-windows.zip`, with launch instructions and the source revision. Do not commit ZIPs. Public upload/release requires owner approval.
- Continue a later session by opening this folder in Codex or Claude and saying "continue". Verify tool availability and re-read saved answers before taking the next roadmap step.
