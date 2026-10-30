# Trailomon visual direction

Standing requirements: avoid generic AI-generated art and interface patterns; use distinct iconography as a practical aid from the first playable onward.

The visual idea is a well-used field guide brought to life: a small wagon, readable animal silhouettes, changing country, and clear marks for the things a traveler needs to notice. A quiet journey should occupy more attention than its controls.

## Palette and composition

Use ink-dark green for structure, warm paper for legibility, muted plant colors for the landscape, and amber for attention. Clay red marks harm or a cost that deserves care. These colors must reinforce written information, never replace it. Keep surfaces flat and texture restrained so small sprites remain readable.

The main composition follows the wagon's journey. A narrow status ledger holds supplies and crew condition. Decision screens concentrate on the situation, its visible cause, and the available responses. Avoid presenting every piece of information as an equally prominent card.

## Icon language

The first icon set is authored in code on a shared pixel grid. It uses simple silhouettes, consistent stroke weight, and enough negative space to remain legible at small sizes. The same source is used everywhere in the interface.

| Concept | Visual cue | Meaning beside the label |
| --- | --- | --- |
| Provisions | Grain stalk | Food available or consumed |
| Coins | Ringed coin | Spending and payment |
| Wagon | Cart and wheels | Vehicle condition and hauling |
| Cargo | Sprouting cutting | The living orchard delivery |
| Condition | Heart | Health or injury |
| Stamina | Hoof print | Available effort |
| Repairs | Hammer | Repair stock or repair action |
| Medicine | Marked bottle | Treatment supplies |
| Time | Sun dial | Days, waiting, and duration |
| Capacity | Pack | How much the wagon can carry |
| Scouting | Eye | Information and route finding |
| Water | Waves | Swimming, crossings, and wet conditions |
| Guard | Shield | Protection from the displayed threat |
| Discovery | Open book | Recorded observations and memories |

Icons accompany labels in resource summaries, creature roles, travel commands, and battle choices. Disabled actions retain their label and state the missing requirement. Show costs with the same resource symbols used by the supply ledger. Pair danger colors with a word or number.

## Asset review

The current creature PNGs are selected Sprite Fusion studies. They establish an earthy palette, but they are not a locked production style. Brindlehorn still needs a stronger hollow-antler design, Reedskipper needs a clearer paddle-tail silhouette, and the roster needs a consistent camera angle and shared scale. These are explicit follow-up art tasks.

Before a creature is considered finished, inspect it at its on-road size beside the wagon, in grayscale, and beside the other five species. Its role should be visible without copying a familiar franchise silhouette. Avoid noisy micro-detail, unrelated anatomy, ornamental accessories, and inconsistent perspective. Approve a pose before producing frame animation or other directions.

Normal maps and eight-direction sheets are outside the current side-view prototype budget. The landscape and interface symbols are native code; creature generation must support the overall art direction rather than determine it by default.
