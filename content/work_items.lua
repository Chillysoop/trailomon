-- One of each object per expedition; each companion has one slot.
return {
    order={"padded_trace","release_rope","dry_wrap"},
    defs={
        padded_trace={name="Padded trace",price=12,weight=4,icon="haul",
            travel="Hurried hauling costs 3 less energy.",
            battle="Approach: first damaging hit loses up to 6 harm."},
        release_rope={name="Release rope",price=10,weight=3,icon="water",
            travel="Halves food and cargo loss in a bad crossing.",
            battle="Wearer fighting: scavenger retreat loses at most 4 food / 4 cargo."},
        dry_wrap={name="Dry wrap",price=8,weight=2,icon="rest",
            travel="With meals in rain: wearer recovers 3 extra energy.",
            battle="Bellmoth keeps its full 16-cover shimmer in rain."},
    },
}
