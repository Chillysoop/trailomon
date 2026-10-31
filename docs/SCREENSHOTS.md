# Automatic rendered screenshots

Owner-approved speed-1 F1, October 30, 2026. From PowerShell at the project root:

```powershell
./tools/capture.ps1
./tools/capture.ps1 -Scenes options,options_brisk,combat_setup,combat_ready
```

The command opens an isolated hidden Windows release renderer, draws the production interface, performs scripted production button callbacks, saves real PNGs at 1280×720 and exits. It does not require Computer Use, desktop focus or a debug server. The first run downloads/builds the pinned native capture dependency; subsequent runs retain that cache. A graphics-capable Windows session is required; the null/headless renderer cannot produce visual evidence.

Output lives in a unique `.tools/captures-<timestamp>/Trailomon Capture/` folder. `.tools/latest-captures.txt` names the latest successful folder. PNGs accompany `capture-result.json`, `source.json` (source revision, dirty flag and input hashes), `timing.json`, and stdout/stderr. The command rejects timeout, failed fixtures, missing results, wrong frame size and a capture-count mismatch. Inspect the PNGs; passing assertions alone cannot establish good layout.

The first proof covers Options, changing its viewing-speed button, combat selection, and choosing two companions then opening the first intent. All four were visually inspected with correct orientation, palette, readable labels and no clipping. The cached four-screen run took about four seconds on the owner's machine. This is an observation, not a speed guarantee.

## Isolation and extension

`tools/capture_prepare.py` mirrors only game/test inputs into `.tools/capture-project`. Unchanged inputs and its native cache survive subsequent runs. The test-only `tests/screenshots.project` supplies its collection and dependency; the player's `game.project` and executable do not gain a capture extension. Fixtures construct fresh deterministic state and do not import the save service. Attempting an explicit save fails the fixture. No player profile is loaded or written.

Add a case to `tests/capture_fixtures.lua` and the script's `Scenes` allow-list when a feature needs another screen. Use queued action keys to run one real button callback per frame; coalesce redraws as the game does. Set a state assertion where useful. Four settled frames precede asynchronous post-render capture. Windows desktop scaling is normalized by `window.set_size`, and the returned framebuffer dimensions are checked.

The MIT-licensed [defold-screenshot dependency](https://github.com/britzl/defold-screenshot/tree/5f3098e3bfc37e8f26bde9428436b4d4499d1d50) is pinned to that revision in the test project. [Upstream license](https://github.com/britzl/defold-screenshot/blob/5f3098e3bfc37e8f26bde9428436b4d4499d1d50/LICENSE.md). Defold 1.13.2's Windows release engine was verified. This path exercises real rendering and UI callbacks, not physical keyboard/mouse delivery, audio quality, Windows activation, or human pacing. The known native activation crash is still open.
