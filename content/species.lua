local M = {}
M.order = {"brindlehorn", "reedskipper", "loamling", "bellmoth", "cindercoil", "slatewhorl"}
M.defs = {
    brindlehorn = {name="Brindlehorn", cost=4, draft=true, upkeep=1.2, pressure=13,
        friend="Moss", temperament="Steadfast", role="Haul & brace", ability="Braces the wagon; protects cargo.",
        assist="Antler brace", help="brace", color="c48b55", initial=true},
    reedskipper = {name="Reedskipper", cost=3, draft=true, upkeep=1.0, pressure=11,
        friend="Puddle", temperament="Playful", role="Haul & swim", ability="Secures a crossing line; redirects threats.",
        assist="Paddle sweep", help="swim", color="72a397", initial=true},
    loamling = {name="Loamling", cost=3, upkeep=0.8, pressure=12,
        friend="Buttons", temperament="Curious", role="Forage & dig", ability="Finds roots and soft ground; disrupts footing.",
        assist="Root hollow", help="dig", color="aa8766", initial=true},
    bellmoth = {name="Bellmoth", cost=2, upkeep=0.5, pressure=10,
        friend="Lumen", temperament="Watchful", role="Scout & distract", ability="Finds trail markings; distracts a threat.",
        assist="Dusk shimmer", help="scout", color="d7bd72", initial=true},
    cindercoil = {name="Cindercoil", cost=3, upkeep=0.8, pressure=14,
        friend="Ember", temperament="Gentle", role="Warm & dry", ability="Warms cold camps and dries damp cargo.",
        assist="Warmth display", help="warm", color="d58760"},
    slatewhorl = {name="Slatewhorl", cost=3, draft=true, upkeep=1.0, pressure=10,
        friend="Flint", temperament="Patient", role="Anchor & shield", ability="Anchors a crossing line and shields companions.",
        assist="Stone shelter", help="anchor", color="899c9b"},
}
return M
