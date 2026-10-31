# Review decisions and delivery

2026-10-31 next-2: five new D1–D5 options after the creature batch; top picks D1/D2/D3. Initially unanswered. Published owner-private at /next-2.html; 12 review tests and isolated Edge YES/NO/comment/FINISH/hide-answered/phone checks passed. See next-steps.md for meanings, dependencies and audit. No previously approved controls are repeated.

2026-10-31 wild-1 revision 7: W1–W6 all YES, no notes. Implement in dependency order: W1/W2 wildlife and guide; W3/W4 courier spar and recognition; W5 discovery starts; W6 learned habits. These approvals expand the first expedition, not its geography or art scope. See creature-encounters.md for delivery. No rejected or blank items.

2026-10-31 owner direction: only send or open a YES/NO review when there are genuinely unanswered decisions. Approved implementation work is not an open question. Previously voted items are hidden by default, with explicit Show answered items history. Votes and notes stay saved. New draft votes remain visible for comments until FINISH. Completed pages say No open decisions and hide redundant actions; top picks never overwrite existing answers. Do not resend completed reviews after each feature or invent choices to fill a quota.

Phone reviews use the owner-private Site in reviews/hosted-site.json. Source is maintained through Sites in the ignored .tools/phone-review-site checkout. Canonical UI is reviews/review.js and review.css; sync with tools/sync_hosted_review.py. Preserve the Site identity, private audience, codes and stored answers. Test only isolated local fixtures/databases; never write synthetic production votes. Credentials belong in memory/stdin only.

Check hosted review_submissions using database overview and paginated complete rows, then import with tools/import_hosted_review.py. Read every local response, including note-only and late edits. FINISH writes an immutable submission snapshot; later draft autosaves do not alter it. Track imported revision/finished_at to avoid acting twice. Browser FINISH cannot wake an ended turn; check again next session.

Decisions:
- 2026-10-30 plan-1 revision7: P1–P5 all YES, no notes. Automatic combat, bounded gathering (hunting deferred), wilderness, creature art and three work items. Later chat defers art to the owner's overhaul; other approvals persist.
- 2026-10-30 next-1 revision34: N1–N8 YES. General note makes thoughtful consistent icons and visible simplicity critical path. N2 authorizes combat-1 C1/C3; N3 authorizes C2. C4 continuous clocks was unapproved and remains out of scope. See next-steps.md for statuses and scope.
- 2026-10-31 journey-1 revision5: J1–J4 all YES, no notes; implemented in PR14. See choice-clarity.md.
- 2026-10-31 next-1 revision42: N1–N11 all YES, no amendments; N9–N11 add trail reports, two event chains and three journal aims. N9 shipped PR25; N10 shipped PR27; N11 is implemented in the journal-aims batch. No repeat vote. N6's old YES is superseded by the owner-led art deferral. No rejected ideas in these three submissions.

Raw answers remain git-ignored. Summarize decisions here and in subject notes; do not copy credentials from comments. Chat corrections override prior votes. Blank ideas after FINISH remain unbuilt and must not be repeatedly proposed. No new owner votes were written during the answered-item UI change. Browser QA covers loaded approvals, new decisions added later, history, saved notes, top-pick preservation, FINISH, offline fallback, and phone/light/dark layouts.

2026-10-31 balance-1: two new unanswered choices after the S5 study, E1 richer woodland gathering and E2 Slatewhorl sure footing. Both top picks; numerical proposals remain unbuilt until answered. The page includes the automated report and already-fixed bugs in expandable sections. See balance-study.md. Existing N1–N11 approvals are not shown again.

Publication: shared open-only view deployed to the same owner-private Site. The deployment now returns https://trailomon-owner-reviews.chillysoop.chatgpt.site; hosted-site.json records that canonical URL. Existing revision42 approvals were unchanged at closeout. No new review link was sent because nothing needs a decision.
