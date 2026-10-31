# Discovery tracks

2026-10-31: chat “proceed” accepts the last explicit D1/D2/D3 recommendation. Hosted next-2 has no submitted/draft votes. D4/D5 and balance E1/E2 remain unapproved. Existing art retained.

D1: Discovery can meet the missing Brindlehorn at Split Oak or Reedskipper at Willowford through Journey → Wildlife nearby. Meeting is free, invitation costs 4 food, max crew 3; daily meals and remaining food days use existing preview. Pass is always available. Invitations are once per run and returning retains the recruit. Full crews must leave room on a later expedition; there is no roadside dismissal added.

D2: all six species have habitat/landmark and method hints in Species field guide. Reports stay labeled unconfirmed until the player observes that species; reading changes no knowledge or RNG. Existing flag/scout/crew/resource symbols are reused.

D3: new journeys initialize tracks. Departure and each route exit save a species/event/roll/used record keyed by destination stretch; local seeded sampling does not consume weather/events/combat RNG. Search uses one day plus exact meals, normal weather/recovery, no wagon progress. About 20% of seeded signs lead to empty shelter. Found events reuse their usual optional costs. Once used or already resolved naturally, no further search on that stretch. Hunger, last-day closure, encounters and unread road stories block it without mutation. Terminal exposure ends the journey before granting any event. Old saves lacking tracks remain valid and enable searches next trip.

Validation: 112 Lua scenarios; both hauler invitations, retention, crew/food guards, guide purity, save-before-choice and no-reroll, found/empty tracks, invalid records and terminal boundaries. 24 complete search-enabled reference journeys (two starters, seeds 1–12), each replayed exactly; no stalls. Native save/reload of plans, spent searches and Discovery invitation/retention plus 36 existing GUI states pass. Seven actual 1280×720 screenshots inspected in reviews/evidence/tracking. Reference policies do not prove optimal balance or human pacing.
