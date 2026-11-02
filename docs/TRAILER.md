# Twenty-second creature-trail teaser

2026-11-01 owner request: a hype trailer showing the core loop and the combination of creature collecting with original Oregon Trail travel. Delivered as a private MP4 preview, not a public release.

Watch: https://trailomon-owner-reviews.chillysoop.chatgpt.site/trailer.html

| Time | Beat |
|---|---|
| 0–2.5s | What if the Oregon Trail was a creature collector? Actual meadow travel. |
| 2.5–5s | Find your crew. Share food, invite Loamling, see the new companion. |
| 5–7s | Build your battle team. Real expedition crew, formation and carried gear. |
| 7–9.5s | Pack supplies, depart, spend a day and meet a roadside choice. |
| 9.5–11s | Choose a river crossing; pay for the ferry. |
| 11–17.5s | They fight. You survive. Real road combat at 2x, repeating skills and subtle attack/ability motion. |
| 17.5–20s | Trailomon: creature collecting, old-school survival. Upland journey and six creatures. |

1280×720, H.264/AAC, 30fps, exactly 600 frames / 20seconds, fast-start MP4. Original synthesized E-minor plucked/retro score and percussion, normalized to -16LUFS with a -1.5dBTP limit. No third-party recording or reference-game artwork. Existing game font, sprites and scenes only. Captions/crops/close-ups are editorial overlays. The disclosure says edited prototype footage; combat uses the implemented S30 expedition encounter and actual carried gear. The owner specifically requested a stronger Astronarch/creature-collector versus Oregon Trail trailer; the revised cut expands combat from four to six-and-a-half seconds and puts party building ahead of survival decisions. Do not imply 300 implemented creatures.

## Rebuild

1. `./tools/trailer_capture.ps1` captures 600 frames using the isolated release renderer and production UI/model callbacks. No player saves or debug listeners. It writes the source directory to `.tools/latest-trailer-footage.txt`.
2. Run `tools/render_trailer.py` with Python providing Pillow and NumPy, plus `--ffmpeg <path>`, or install `imageio-ffmpeg==0.6.0` under `.tools/trailer-deps`. The configured workspace Python already supplies Pillow/NumPy.
3. Output: `reviews/evidence/trailer/Trailomon-20s.mp4`, poster, representative frames and provenance manifest. Raw frames/audio/build caches stay ignored under `.tools`.
4. `python tools/sync_hosted_review.py .tools/phone-review-site` includes the small finished video in the existing private Site publication.

Validation is recorded in `reviews/evidence/trailer/verification.json`: full 600-frame decode, 20s metadata, 48kHz stereo AAC, no clipping, and phone light/dark playback. Nine composed frames inspected. No human listening review claimed. Trailer-only checks reuse the passed S30 game/save evidence. S30 itself receives one updated Windows bundle after merge.
