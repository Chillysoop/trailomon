# Twenty-second creature-trail teaser

2026-11-01 owner request: a hype trailer showing the core loop and the combination of creature collecting with original Oregon Trail travel. Delivered as a private MP4 preview, not a public release.

Watch: https://trailomon-owner-reviews.chillysoop.chatgpt.site/trailer.html

November 2 revision: the owner asked to sell the vision through a journey, rather than flash between screens. One Brindlehorn and one recruited Loamling remain the protagonists from meeting to the remote destination. No menu montage or inspector text is needed to follow the story.

| Time | Story beat |
|---|---|
| 0–6s | Find a companion. Find a reason to keep going. Loamling approaches and joins; sharing food changes provisions from 90 to 86 and crew from one to two. |
| 6–10s | Supplies run low. The road gets wilder. The same pair travels through rain; real meals reduce provisions to 80. |
| 10–16s | Build your crew. Protect what you carry. Hold on the real S30 battlefield: Moss intercepts while Buttons attacks and uses Underhook. |
| 16–20s | Trailomon: creature collecting, old-school trail survival. The same crew continues into the high country beneath the title. |

Each moment holds 4–6 seconds; three 0.4-second dissolves replace the previous seven-shot montage. The same musical theme carries across every transition. Actual shared resource icons stay readable, and the end card preserves full creature silhouettes.

1280×720, H.264/AAC, 30fps, exactly 600 frames / 20 seconds, fast-start MP4. Original synthesized E-minor score, normalized to -16 LUFS with a -1.5 dBTP limit. No third-party recording, new generated art or reference-game footage. The new source capture uses existing production scenery, sprites, UI marks and combat. The same actual snapshot supplies recruitment, meals, Condition and combat. Geography is time-compressed by staging landmarks; the entrance is editorial. The video and page disclose staged in-engine vignettes; this is not a claim of uninterrupted gameplay or a changed shipping interface. Only the two existing protagonist species and current wild foes appear.

## Rebuild

1. `./tools/trailer_capture.ps1` captures 600 frames using the isolated release renderer, production scenery and model callbacks. No player saves or debug listeners. It writes the source directory to `.tools/latest-trailer-footage.txt`.
2. Run `tools/render_trailer.py` with Python providing Pillow and NumPy, plus `--ffmpeg <path>`, or install `imageio-ffmpeg==0.6.0` under `.tools/trailer-deps`. The configured workspace Python already supplies Pillow/NumPy.
3. Output: `reviews/evidence/trailer/Trailomon-20s.mp4`, poster, representative frames and provenance manifest. Raw frames/audio/build caches stay ignored under `.tools`.
4. `python tools/sync_hosted_review.py .tools/phone-review-site` includes the small finished video in the existing private Site publication.

Validation is recorded in `reviews/evidence/trailer/verification.json`: full 600-frame decode, 20s metadata, 48kHz stereo AAC, no clipping, and phone light/dark playback. Nine composed frames and the full-size combat/end card inspected; 4–6-second beat durations verified. No human listening review claimed. Trailer-only checks reuse the passed S30 game/save evidence. S30's existing clean Windows bundle remains current; this media-only revision needs no new player ZIP.
