# Review decisions and delivery

2026-10-31 next-2: five new D1–D5 options after the creature batch; top picks D1/D2/D3. Chat “proceed” approved the recommended D1–D3; no next-2 submission or draft exists. D4/D5 remain undecided. D1–D3 descriptions move into completed history without fabricating votes. See next-steps.md for delivery and audit.

2026-10-31 wild-1 revision 7: W1–W6 all YES, no notes. Implement in dependency order: W1/W2 wildlife and guide; W3/W4 courier spar and recognition; W5 discovery starts; W6 learned habits. These approvals expand the first expedition, not its geography or art scope. See creature-encounters.md for delivery. No rejected or blank items.

2026-10-31 owner direction: only send or open a YES/NO review when there are genuinely unanswered decisions. Approved implementation work is not an open question. Previously voted items are hidden by default, with explicit Show answered items history. Votes and notes stay saved. New draft votes remain visible for comments until FINISH. Completed pages say No open decisions and hide redundant actions; top picks never overwrite existing answers. Do not resend completed reviews after each feature or invent choices to fill a quota.

Phone reviews use the owner-private Site in reviews/hosted-site.json. Source is maintained through Sites in the ignored .tools/phone-review-site checkout. Preserve identity/audience/codes/answers. Sync with tools/sync_hosted_review.py. Test fixtures only; credentials stay in memory/stdin.

Check hosted review_submissions using database overview and paginated complete rows, then import with tools/import_hosted_review.py. Read every local response, including note-only and late edits. FINISH writes an immutable submission snapshot; later draft autosaves do not alter it. Track imported revision/finished_at to avoid acting twice. Browser FINISH cannot wake an ended turn; check again next session.

Decisions:
- 2026-10-30 plan-1 revision7: P1–P5 all YES, no notes. Automatic combat, bounded gathering (hunting deferred), wilderness, creature art and three work items. Later chat defers art to the owner's overhaul; other approvals persist.
- 2026-10-30 next-1 revision34: N1–N8 YES. General note makes thoughtful consistent icons and visible simplicity critical path. N2 authorizes combat-1 C1/C3; N3 authorizes C2. C4 continuous clocks was unapproved and remains out of scope. See next-steps.md for statuses and scope.
- 2026-10-31 journey-1 revision5: J1–J4 all YES, no notes; implemented in PR14. See choice-clarity.md.
- 2026-10-31 next-1 revision42: N1–N11 all YES, no amendments; N9–N11 add trail reports, two event chains and three journal aims. N9 shipped PR25; N10 shipped PR27; N11 is implemented in the journal-aims batch. No repeat vote. N6's old YES is superseded by the owner-led art deferral. No rejected ideas in these three submissions.

Raw answers remain git-ignored. Chat comments override votes; blanks remain unbuilt. Never fabricate owner votes. Existing browser QA covers hidden answers/history, notes, FINISH, fallback and phone/light/dark layout.

2026-10-31 balance-1: two new unanswered choices after the S5 study, E1 richer woodland gathering and E2 Slatewhorl sure footing. Both top picks; numerical proposals remain unbuilt until answered. The page includes the automated report and already-fixed bugs in expandable sections. See balance-study.md. Existing N1–N11 approvals are not shown again.

2026-11-01 identity-1 A1: later chat authorizes and expands combat toward Astronarch with wagon defense, superseding the narrower two-team experiment. Hide A1 from unanswered controls and retain its exact original proposal as history. Do not invent a hosted YES. A2/A3 remain unanswered. Old C4 continuous clocks are now superseded by explicit combat direction.

2026-11-01 bestiary-1 revision 9: B1/B2/B4/B5/B6/B7/B8 YES; B3 NO; no notes/blanks. B1 ability-first and B2 bounded combinations guide S29. B8 first 24 briefs/schema delivered as S31; later authoring remains S36. B4 symbiosis, B5 one learned trick, B6 diet/food-web encounter and B7 migration remain approved queued experiments S32–S35. B3 creature-created battlefield terrain is rejected. See creature-direction.md. The read-only /creature-index.html is a deliverable, not another vote.
