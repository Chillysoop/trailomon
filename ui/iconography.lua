-- Semantic contract: labels and meanings live here, original pixels in icons.lua.
-- Extend a category when a feature ships; never borrow an unrelated glyph.
local M={groups={
    {label="Supplies & time",ids={"food","coins","repairs","medicine","wagon","cargo","capacity","time"}},
    {label="Crew & encounters",ids={"condition","stamina","haul","approach","pressure","guard","assist","crew"}},
    {label="On the road",ids={"trail","map","flag","rest","forage","dig","water","scout","warm","journal","settings"}},
}}
M.defs={
    food={label="Provisions",meaning="Food packed for daily meals.",shape="grain stalk"},
    coins={label="Coins",meaning="Money available for trade and fares.",shape="ringed coin"},
    repairs={label="Repairs",meaning="Materials used to mend the wagon.",shape="hammer"},
    medicine={label="Medicine",meaning="Supplies for a day of treatment.",shape="marked bottle"},
    wagon={label="Wagon",meaning="The vehicle and its condition.",shape="cart and wheels"},
    cargo={label="Cargo",meaning="The living orchard delivery; keep it safe.",shape="sprout in a crate"},
    capacity={label="Load",meaning="Packed weight / wagon capacity.",shape="pack"},
    time={label="Time",meaning="Days spent, time remaining, or playback speed.",shape="sun dial"},
    condition={label="Condition",meaning="Health; zero means care is needed.",shape="heart"},
    stamina={label="Energy",meaning="Effort available for travel and abilities.",shape="hoof print"},
    haul={label="Hauling",meaning="A draft companion pulling the wagon.",shape="yoke"},
    approach={label="Approach",meaning="Forward encounter position; full pressure.",shape="arrow at a boundary"},
    pressure={label="Pressure",meaning="Reduces a threat's resolve.",shape="angular strike"},
    guard={label="Cover",meaning="Reduces harm from the incoming hit.",shape="shield"},
    assist={label="Ability",meaning="A species action with a stated trigger.",shape="four-point spark"},
    crew={label="Crew",meaning="Companions traveling with you.",shape="paw print"},
    trail={label="Journey",meaning="Travel or return to the road.",shape="winding track"},
    map={label="Map",meaning="Landmarks and route choices.",shape="folded map"},
    flag={label="Landmark",meaning="A named stop along the route.",shape="trail pennant"},
    rest={label="Rest",meaning="Camp and allow time for recovery.",shape="tent"},
    forage={label="Gather",meaning="Spend a day finding nearby provisions.",shape="basket and shoot"},
    dig={label="Digging",meaning="Loamling's help with roots and soft ground.",shape="spade"},
    water={label="Water",meaning="River conditions and swimming help.",shape="waves"},
    scout={label="Scouting",meaning="Read the ground and find information.",shape="eye"},
    warm={label="Warmth",meaning="Cindercoil's help with cold and damp.",shape="small flame"},
    journal={label="Journal",meaning="Observations, memories, and symbol guide.",shape="open book"},
    settings={label="Options",meaning="Sound, motion, saves, and seed.",shape="cog"},
}
local roles={brindlehorn="haul",reedskipper="water",loamling="dig",bellmoth="scout",cindercoil="warm",slatewhorl="guard"}
function M.role(id) return assert(roles[id],"Missing species symbol: "..tostring(id)) end
function M.get(id) return assert(M.defs[id],"Unknown symbol: "..tostring(id)) end
return M
