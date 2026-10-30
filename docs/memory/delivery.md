# Delivery

2026-10-30: PR 1 merged as `fad1aa228ed38cdff23c1a76b7e70d0f810300b1`. It contains the already-tested first playable; both Windows CI checks passed before merge. No public release was published.

2026-10-30: PR 2 merged as `58f8dec5b65859bb35c74366d0dbabbf3a7329d9` after both CI checks passed. The private phone review is deployed; the owner's completed P1-P5 YES submission was received and mirrored locally. See `review-pages.md` for the decisions and `reviews/hosted-site.json` for the phone URL.

The Windows bundle was rebuilt from that clean merge at 2026-10-30T22:33:58Z. `builds/Trailomon-windows.zip` and its JSON sidecar identify commit `58f8dec5b65859bb35c74366d0dbabbf3a7329d9`, with `working_tree_changes: false`. The archive includes launch instructions and `build-info.json`; it is a local shareable build, not a published release. Subsequent documentation-only provenance changes do not alter the game in this bundle. Timestamped working bundles remain under `dist/` so an open executable is not overwritten.

Keep public release publication separate from ordinary PR merging. The owner must approve a public release. Windows is the only current target.
