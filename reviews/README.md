# Owner review pages

Start with `./tools/start_review.ps1`, then open `http://localhost:8765/plan-1.html` on this computer. Use YES/NO toggles, comments, and FINISH. The server uses Python's standard library and listens only on loopback; no credentials or outside services are involved. The layout supports a narrow phone-sized viewport, but a separate phone cannot reach this computer through its own localhost.

While an agent session is active, run `py tools/review_server.py --wait plan-1 --timeout 540`. FINISH saves answers and a submission snapshot flag. The command prints that snapshot and consumes the flag. If the session has ended, answers remain available for the next session; a browser alone cannot restart an agent.

Copy `_template.html` for a new page and keep `review.css` and `review.js` beside it. Use a unique page slug, stable idea codes, and three to six top picks. A published code never changes meaning. Every idea needs what, why/evidence, cost, and recommendation. Before publishing, run `py -m unittest discover -s tests -p "test_review*.py"` and `node tools/test_review_browser.cjs` with Playwright available. The browser test uses installed Edge by default; `REVIEW_BROWSER=chromium` selects a Playwright-managed browser. Test responses and screenshots go under `.tools/`, never into the owner's real answers.

Answers retain the requested page/title/general/answers/finished/finished_at/saved_at fields. Additional revision and edit timestamps prevent stale tabs from overwriting newer notes. The server rejects stale writes; the browser merges individual answers by their edit timestamps and retries. FINISH is serialized after pending autosaves. Its flag holds an immutable answer snapshot, so later drafts do not rewrite an earlier submission.

Raw responses stay local and are git-ignored by default. Commit concise decisions to `docs/memory/review-pages.md`. For a remote agent, deliberately attach or commit a downloaded response file instead. Never commit credentials mentioned in comments. Read note-only answers and late updates before closing work.

When the server is unavailable, browser storage retains edits. FINISH downloads a JSON file and tries clipboard copy; the status distinguishes successful copying from a download-only fallback. Paste or attach the answers in chat. An HTML file opened directly can use this fallback even without a running server, provided its neighboring CSS and JavaScript files are present.
