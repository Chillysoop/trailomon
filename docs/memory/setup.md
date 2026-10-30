# Setup

Verified 2026-10-30: local Windows computer, workspace `C:\Users\conne\OneDrive\Documents\ChatGPT\poketrail`; not a cloud sandbox. Existing Defold 1.13.2 builder, LuaJIT, Java 25, Git 2.55, and Python 3.14 work from the command line. No editor installation is required for automated builds. Git name/email are configured; do not repeat private account details in notes.

GitHub connector is authenticated as Chillysoop with repository admin/push access. Repository is `Chillysoop/trailomon`, default branch main. gh is absent; the connected GitHub tools support PR creation and merge, so no gh install is needed. Git fetch works. Existing PR 1 was merged under the owner's new workflow.

Playwright is provided by the Codex runtime; its downloaded Chromium is absent, but the installed Edge browser launches headlessly. Reuse it for review tests without installing another browser. Native game UI automation previously could click but injected keys did not reach Defold; see validation notes.

Review server uses Python standard library and loopback port 8765. Check `/api/health` identifies this repository before reusing a listener. `tools/start_review.ps1` starts it hidden. A phone-sized layout is supported; a phone's localhost does not reach this Windows computer. No LAN sharing is configured.

FINISH is delivered automatically only while a live `--wait` process is monitored by an active agent turn. After a turn ends, answers remain on disk for the next session. If the local server is unavailable, download/clipboard fallback and browser storage retain answers. Tests use isolated response folders, never owner answers.

Setup steps 1–9 are complete locally. The first review is published, continuation instructions were given, and the setup PR still needs CI/merge. Open this folder in Codex or Claude and say "continue" in a later session. Read hosted and local responses before selecting work.

2026-10-30: Owner could not open localhost on a phone. Fixed delivery by deploying the owner-private Site recorded in `reviews/hosted-site.json`. Send its HTTPS URL by default. Same ChatGPT account sign-in is required. Hosted API, private database, and FINISH were tested locally at phone size; native Sites confirmed production deployment. Agent tools read submitted chunks and `tools/import_hosted_review.py` mirrors them into the portable file bridge. No synthetic production answers were written.

PowerShell localhost probes timed out here while IPv4 worked; the local launcher probes `127.0.0.1`. Do not stop another listener because of that hostname timeout.
