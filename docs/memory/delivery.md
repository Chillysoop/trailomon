# Delivery

2026-10-30: PR 1 merged as `fad1aa228ed38cdff23c1a76b7e70d0f810300b1`. It contains the already-tested first playable; both Windows CI checks passed before merge. No public release was published.

2026-10-30: PR 2 merged as `58f8dec5b65859bb35c74366d0dbabbf3a7329d9` after both CI checks passed. The private phone review is deployed; the owner's completed P1-P5 YES submission was received and mirrored locally. See `review-pages.md` for the decisions and `reviews/hosted-site.json` for the phone URL.

The Windows bundle was rebuilt from that clean merge at 2026-10-30T22:33:58Z. `builds/Trailomon-windows.zip` and its JSON sidecar identify commit `58f8dec5b65859bb35c74366d0dbabbf3a7329d9`, with `working_tree_changes: false`. The archive includes launch instructions and `build-info.json`; it is a local shareable build, not a published release. Subsequent documentation-only provenance changes do not alter the game in this bundle. Timestamped working bundles remain under `dist/` so an open executable is not overwritten.

2026-10-30: PR 4 merged as `a466d62e715d10009bb5aa8edf134f4b05aabe15` after both Windows CI checks passed. It ships automatic combat (S3/S4) and the private combat-1 playtest report. Astronarch leads combat mechanics; Automon informs creature-party appeal. S5 tuning remains open.

Previous PR 4 archive was built at 2026-10-30T23:18:31Z. Actual Windows combat playtests preceded merge; Computer Use was stopped during final packaging, so that session did not perform a post-merge launch.

2026-10-30: PR #7 merged as `ad3941e63ae2bc6b38adaa296b2c0ef8aefc8385` after both Windows CI checks passed. It ships N2/N4, S6/S14 and the shared iconography contract. Other N1-N8 approvals remain queued; N1 measurements are next.

Current Windows archive: `builds/Trailomon-windows.zip`, built at **2026-10-31T00:05:41Z** (October 30 locally) from that clean PR #7 merge. `working_tree_changes: false`; SHA-256 `1d7d3e553a0259cb726570cb38678162a27a6646004fcb81d22f26f8df7e81f6`. CRC, seven expected files, README, embedded/sidecar provenance, and clean extraction passed. All five executable/game-data files match the pre-merge playtested build byte for byte. Ordinary launch through Computer Use showed fresh preparation, accepted Begin journey, and saved the paused journey. Only a temporary isolated-save namespace was added to the extracted config for that check, then restored to its original hash; the ZIP was never altered. Earlier full native and focused playtests are in clarity.md.

QA gotcha: launching this Defold release through a hidden PowerShell window, then activating it, reproduced native access violation `0xc0000005` (offset `0x5dc031`); hidden capture also displayed an old underlying window. It reproduced with/without run_while_iconified. Ordinary visible launch succeeded. Treat hidden-launch capture as invalid, use an ordinary game launch for visual tests, and keep this engine/automation limitation open; do not attribute it to a corrupted ZIP. No player code was changed to mask it. CI also warns about upload-artifact v4's deprecated Node 20 declaration but completes successfully. This record-only commit leaves packaged game data unchanged.

Keep public release publication separate from ordinary PR merging. The owner must approve a public release. Windows is the only current target.
