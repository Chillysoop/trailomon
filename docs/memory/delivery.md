# Delivery

2026-10-30: PR 1 merged as `fad1aa228ed38cdff23c1a76b7e70d0f810300b1`. It contains the already-tested first playable; both Windows CI checks passed before merge. No public release was published.

The previous timestamped Windows ZIP was built before the workflow setup. Do not represent it as a build of later documentation or infrastructure commits. The next clean rebuild will record its revision here and write `builds/Trailomon-windows.zip` plus a provenance sidecar. Timestamped working bundles remain under `dist/` so an open executable is not overwritten.

Keep public release publication separate from ordinary PR merging. The owner must approve a public release. Windows is the only current target.
