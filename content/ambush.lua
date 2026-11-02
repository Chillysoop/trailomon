-- Original sample kits. Combat purpose is independent of any species type.
local M={}
M.kits={
    moss={species="brindlehorn",name="Moss",hp=116,def=45,attack=10,interval=22,cost=55,
        skill="Antler brace",active="Shield self 22 + wagon 8",passive="Rooted: +55 DEF in front"},
    ember={species="cindercoil",name="Ember",hp=82,def=8,attack=11,interval=15,cost=50,
        skill="Heat spill",active="Strike target for 26",passive="Follow ally intercepts; faster in front"},
    lumen={species="bellmoth",name="Lumen",hp=68,def=5,attack=6,interval=18,cost=40,
        skill="Dusk shimmer",active="Hit + stun the caller for 1.4s",passive="On stun: lowest ally gets 6 Focus"},
    ripple={species="reedskipper",name="Ripple",hp=94,def=18,attack=9,interval=17,cost=45,
        skill="Paddle sweep",active="Interrupt raider; draw its next attack",passive="Redirect a hit: next attack 0.5s sooner"},
    pip={species="loamling",name="Pip",hp=88,def=5,attack=13,interval=16,cost=40,
        skill="Underhook",active="Expose one foe: +25% harm for 3s",passive="New opening: next attack 0.5s sooner"},
    flint={species="slatewhorl",name="Flint",hp=130,def=38,attack=7,interval=26,cost=50,
        skill="Stone shelter",active="Shield least-protected companion +22",passive="Own shield hit: +4 Focus / tick"},
    raider={species="loamling",name="Root raider",hp=184,def=15,attack=16,interval=24,cost=70,
        skill="Grain rush",active="26 damage toward wagon / intercepted",passive="Raider: lane 1, front can intercept"},
    caller={species="bellmoth",name="Ridge caller",hp=108,def=10,attack=7,interval=19,cost=45,
        skill="Rattle",active="Hit + slow defender for 3s",passive="Targets exposed crew"},
}
M.presets={
    guard={label="Guard the lane",positions={moss=1,ember=3,lumen=4}},
    rush={label="Race the raid",positions={moss=3,ember=2,lumen=4}},
    control={label="Open & punish",crew={"ripple","pip","flint"},positions={ripple=1,pip=3,flint=4},
        items={ripple="padded_trace",pip="release_rope",flint="dry_wrap"}},
}
M.crew={"moss","ripple","pip","lumen","ember","flint"}
M.mara={
    raider={species="brindlehorn",name="Mara's Brindlehorn",skill="Practice rush",active="26 damage toward practice wagon",passive="Front lane 1 can intercept"},
    caller={species="bellmoth",name="Mara's Bellmoth",skill="Practice rattle",active="Hit + slow defender for 3s",passive="Targets exposed crew"},
}
M.by_species={brindlehorn="moss",reedskipper="ripple",loamling="pip",bellmoth="lumen",cindercoil="ember",slatewhorl="flint"}
-- Fixed road opponents, not scaled to the player's crew. Quiet options remain.
M.road={
    scavengers={raider={hp=110,name="Grain raider"},caller={hp=60,name="Thicket lookout"}},
    territorial={raider={hp=184,species="slatewhorl",name="Ridge warden",skill="Boundary rush"},caller={hp=108,name="Ridge caller"}},
}
M.item_order={"", "padded_trace","release_rope","dry_wrap"}
-- 1/2: front lanes 1/2. 3/4: rear lanes 1/2.
M.positions={"Front 1","Front 2","Rear 1","Rear 2"}
return M
