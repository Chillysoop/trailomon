# Desktop launcher

2026-11-03 owner asked for a desktop shortcut that automatically updates to the latest game. This explicitly authorizes creating Trailomon.lnk on the Windows desktop and supersedes speed-1 F2's previous unapproved state. Implemented as S39 / PR #52: a stable tools/play.ps1 target resolves .tools/latest-bundle.txt at each click. build.ps1 already writes that pointer only at successful completion. It follows local built versions, not remote GitHub releases, and does not rebuild on launch.

Installed at the OS-resolved Desktop (currently C:/Users/conne/OneDrive/Desktop/Trailomon.lnk). Windows PowerShell runs hidden, starts the release game normally, and exits. The icon is copied from the existing executable into ignored .tools/trailomon-launcher.ico so old build cleanup cannot break it. No firewall rules, engine mode or save namespace changed. The project folder must remain in place; rerun tools/install_shortcut.ps1 after moving it.

If the pointer is missing/stale/incomplete/outside repo dist, choose the newest complete Windows bundle by build-info timestamp. Require the executable, four data files and recognized build metadata. Missing game shows a short error. No deletion, automatic Git checkout or downloads.

Validation: four Windows PowerShell regression scenarios cover changed pointers, stale/missing pointers, incomplete/external bundles and no game. Actual installed .lnk launched the expected release executable with a Trailomon window in 1.62 seconds; left open for the owner. Existing gameplay evidence reused because game inputs are unchanged. CI retains full checks for tooling changes.

Current player build: PR51/e0bbbea688e9b2b37fefbf499b70e0b0e75e741a, built 2026-11-02, SHA256 f35a3f686aca421115aac03101d200ef61ed49f5ff82fb7a1f8f9c27e73a9499. See .tools/commons-delivery.json. This launcher-only change needs no new player ZIP. Hosted answers unchanged at start; no new review decision or page.
