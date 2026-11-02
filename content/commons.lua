-- Habitat, travel bed and homecoming share one authored source.
local M={}
M.defs={
    brindlehorn={habitat="Open meadows",bed="Grass-lined sling",home="Meadow paddock",method="Shared a meadow meal",event="meet_brindlehorn",
        arrival="The empty paddock answers with a hollow antler call. Fernwake's herd calls back."},
    reedskipper={habitat="Shallow river margins",bed="Reed travel cradle",home="Reed pool",method="Shared a riverbank meal",event="meet_reedskipper",
        arrival="A floating nest appears in the old reed pool. Every loose stem has been put to use."},
    loamling={habitat="Soft meadow and woodland soil",bed="Straw waybasket",home="Orchard beds",method="Followed your root trail",event="discover_loamling",
        arrival="The orchard's hard beds become small, crooked tunnels. Something is living beneath them again."},
    bellmoth={habitat="Dry woodland roosts",bed="Shaded roost cloth",home="Lantern shed",method="Chose your shaded roost",event="discover_bellmoth",
        arrival="Folded wings line the lantern shed. At dusk, their reflections make the old windows glow."},
    cindercoil={habitat="Sheltered stone hollows",bed="Dry felt nest",home="Warm stone nook",method="Returned after you sheltered it",event="cinder_return",
        arrival="The cold stones beside the washhouse hold a little warmth long after sunset."},
    slatewhorl={habitat="Loose upland shale",bed="Low slatted bed",home="Shale bank",method="Returned after you freed it",event="slate_return",
        arrival="A broad shell settles into the shale bank. The loose stones finally have a quiet neighbor."},
}
return M
