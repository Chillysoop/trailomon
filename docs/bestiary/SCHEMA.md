# Creature index v1

Approved B8 first deliverable, November 1, 2026. `index.json` is an authoring ledger, not a second runtime species table. The game still reads `content/species.lua`. Generate the phone-readable ledger with `python tools/bestiary.py`; check it without writing with `python tools/bestiary.py --check`.

## Identity and counting

- `schema`: integer version, currently 1. `minimum_species`: 300. This is the intended implemented-game target, not a claim about current content.
- `regions`: five provisional production allocations totaling 300 slots. Each records an ID, name, environment and first/last index number. The four farther regions come from the existing proposed world lore; they are not new playable maps.
- `entries`: exactly one record per allocated index number. `index_id` is permanent (TR-001 etc.). Never reuse a retired identity or renumber an entry when its region changes. Add slots above TR-300 when required.
- A `reserved` record contains only `index_id`, `region_id` and `design_status`. It is a vacant slot, never a named or designed species. A `brief` record must supply the fields below. Every authored brief is a distinct species; forms/recolors require a parent and a later explicit schema change, not another species count.
- Existing stable species IDs and names are checked against `content/species.lua`. The first six ledger IDs are fixed to that existing roster. New slugs are authoring IDs until implemented. `design_status=brief` means an editorial first draft, not final art, balance or an approved individual species.

## Required brief fields

| Field | Contract |
| --- | --- |
| `species_id`, `name` | Unique lowercase slug and display name |
| `game_status` | `implemented` or `planned`; implemented IDs must exactly match the runtime roster |
| `kit_status` | `sample` or `proposed`; sample means the S28 companion kit exists, not expedition integration |
| `art_status` | `existing` or `deferred`; existing means there is an asset, not that the owner's overhaul is finished |
| `role` | Plain description of life in the world; descriptive tags do not form classes or a matchup chart |
| `body` | Distinct silhouette/anatomy that supports the behavior; no asset request |
| `habitat`, `diet`, `ecology` | Where it lives, what it eats, why it belongs there; food-web links use existing ledger species IDs |
| `behavior` | One memorable thing a player could observe |
| `encounter`, `recruitment` | How it might be found; `existing`, `planned_companion` or `observation_only`. Planned means design, not a runtime encounter |
| `active`, `passive` | Each has a name, behavior, trigger and explicit bound/tradeoff; proposed kits are not tuned statistics |
| `emits`, `responds_to` | Shared behavior-event vocabulary for combinations; these describe actions, never creature types |
| `counterplay` | How another kit or decision can answer its strength |
| `tradeoff` | Why it would not replace every other team member |
| `integration` | What is already present, and which authorized step would implement the remaining work |

The initial vocabulary is strike, brace, intercept, interrupt, bind, expose, shield, shed, charge, perch, stagger, recover, repeat, and fall. An author can add a verb deliberately with a definition. Do not add elemental multipliers, terrain mutation, hidden immunities or unbounded recursive triggers. B3's creature-created battlefield conditions were rejected. Binding an individual enemy is allowed by B2; changing a terrain slot is not.

## Production checks

Run `python -m unittest discover -s tests -p test_review_bestiary.py`. Validation checks ID/range uniqueness, exact reserved-record shape, required biology/kit/counterplay fields, supported statuses, cross-species food-web references, runtime status honesty and stable existing IDs. These checks find structural mistakes; an editorial read must still judge whether the creatures are interesting, distinct and coherent. New species and kits remain drafts until implemented and tested.

The read-only HTML is generated deterministically from the ledger with escaped text. Search, region filters and stable per-creature anchors work on a phone. There are no approval controls because B8's first deliverable is already authorized. The earlier bestiary-1 votes remain the decision record; approved/rejected cards stay hidden by its normal answered-item behavior.
