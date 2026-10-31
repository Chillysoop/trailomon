# Owner review pages

Only send or open a YES/NO page when the owner has an unanswered decision. Approved work awaiting implementation is not an open decision. Previously voted items are hidden by default; **Show answered items** reveals history without deleting votes or notes. New votes stay visible for comments until FINISH. A fully answered, submitted page says **No open decisions** and hides FINISH/top-pick actions until editing resumes. Top picks never overwrite an existing YES or NO. Report-only updates do not need a review link.

Open the [private hosted review](https://trailomon-owner-reviews.chillysoop.chatgpt.site/plan-1.html) on a phone or computer and sign in with the owner's ChatGPT account. It supports YES/NO toggles, comments, autosave across devices, and FINISH. Hosted answers use private Sites storage. No tokens are included in the page.

For a desktop-only local fallback, run `./tools/start_review.ps1`, then open `http://localhost:8765/plan-1.html` on the Windows computer. The Python standard-library server listens only on loopback. A phone's localhost points to the phone, so never send that link as the phone delivery path.

## Hosted answer bridge

`hosted-site.json` records the verified Site identity and private URL. Read Sites database overview first, then every page of the exact returned `review_submissions` table. Use returned pagination offsets, verify no values were truncated, and pass the combined `{"rows": [...]}` through stdin to `python tools/import_hosted_review.py`. It validates chunk order and revision, restores the normal response JSON and FINISH flag, and avoids duplicate processing. Newer local answers are preserved as a conflict for the agent to reconcile. Submission chunks remain immutable across later draft autosaves.

During active work with an unanswered relevant decision, poll about every 15–30 seconds. Once answers are consumed, check at session start and closeout. Optional tooling proposals do not hold a finished update open for an idle hour. FINISH requires no extra chat message while the agent is active. After a turn ends, the next session checks hosted submissions before choosing work. An agent without Sites access must not claim to be monitoring the hosted page.

## Updating the hosted page

Follow the installed Sites skill and reuse the ID in `hosted-site.json`. The dedicated ignored checkout is `.tools/phone-review-site`; Sites keeps its source in its own managed repository. Canonical shared UI lives here, and the backend/schema live under `tools/hosted_review/`. Run `python tools/sync_hosted_review.py .tools/phone-review-site` to synchronize. Preserve all applied database migrations; generate only new schema migrations when needed and retain them with the canonical backend.

Use the Sites source helper, validate/build, and deploy owner-private without changing the audience. Keep source credentials in session memory/stdin only. Test the hosted backend against the isolated local Sites development database with `node tools/test_hosted_review.cjs`; never seed synthetic owner votes into production. Update `hosted-site.json` after confirmed publication and commit the authored changes in the game's PR.

## Local answer bridge

While an agent session is active, run `py tools/review_server.py --wait plan-1 --timeout 540`. FINISH saves answers and a submission snapshot flag. The command prints that snapshot and consumes the flag. If the session has ended, answers remain available for the next session; a browser alone cannot restart an agent.

Copy `_template.html` for a new page and keep `review.css` and `review.js` beside it. Use a unique page slug, stable idea codes, and three to six top picks. A published code never changes meaning. Every idea needs what, why/evidence, cost, and recommendation. Before publishing, run `py -m unittest discover -s tests -p "test_review*.py"` and `node tools/test_review_browser.cjs` with Playwright available. The browser test uses installed Edge by default; `REVIEW_BROWSER=chromium` selects a Playwright-managed browser. Test responses and screenshots go under `.tools/`, never into the owner's real answers.

Answers retain the requested page/title/general/answers/finished/finished_at/saved_at fields. Additional revision and edit timestamps prevent stale tabs from overwriting newer notes. The server rejects stale writes; the browser merges individual answers by their edit timestamps and retries. FINISH is serialized after pending autosaves. Its flag holds an immutable answer snapshot, so later drafts do not rewrite an earlier submission.

Raw responses stay local and are git-ignored by default. Commit concise decisions to `docs/memory/review-pages.md`. For a remote agent, deliberately attach or commit a downloaded response file instead. Never commit credentials mentioned in comments. Read note-only answers and late updates before closing work.

When the server is unavailable, browser storage retains edits. FINISH downloads a JSON file and tries clipboard copy; the status distinguishes successful copying from a download-only fallback. Paste or attach the answers in chat. An HTML file opened directly can use this fallback even without a running server, provided its neighboring CSS and JavaScript files are present.
