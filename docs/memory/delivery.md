# Delivery

Latest Windows build: use `builds/Trailomon-windows.json` for authoritative commit/dirty-state provenance. Current gameplay delivery notes: [wagon-ambush.md](wagon-ambush.md). Historical archives below are superseded.

Earlier build/merge provenance is in git history and historical delivery subject notes. Rebuild player archives for meaningful gameplay batches, not documentation-only changes.

QA gotcha: launching this Defold release through a hidden PowerShell window, then activating it, reproduced native access violation `0xc0000005` (offset `0x5dc031`); hidden capture also displayed an old underlying window. It reproduced with/without run_while_iconified. Ordinary visible launch succeeded. N8 later reproduced the same offset during visible-game reactivation after a firewall interruption; cause remains unproven (see journey-playtest.md). Treat hidden-launch capture as invalid, use an ordinary game launch for visual tests, and keep the native fault open; do not attribute it to a corrupted ZIP. No player code was changed to mask it. CI also warns about upload-artifact v4's deprecated Node 20 declaration but completes successfully. This record-only commit leaves packaged game data unchanged.

Keep public release publication separate from ordinary PR merging. The owner must approve a public release. Windows is the only current target.

2026-11-01 S28: PR40 merged as f8a930abddbda85dd690daf86c1446359e25e8ee. Clean Windows ZIP SHA256 a199a611dbd361bde58501ecf928e6d6ee50e8684df8fb0cdd4c1d3c3a790587, 3,945,915 bytes. 122 Lua scenarios, native checkpoint/UI, 48 comparisons, five rendered screens and CI passed; ZIP CRC/provenance checked. B8 authoring/catalog work changes no runtime inputs and requires no replacement player ZIP.
