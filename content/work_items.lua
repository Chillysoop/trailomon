-- One of each object per expedition; each companion has one slot.
return {
    order={"padded_trace","release_rope","dry_wrap"},
    defs={
        padded_trace={name="Padded trace",price=12,weight=4,icon="haul",
            wagon="DEF +18; intercept +3 Focus; attacks 0.2s slower",
            travel="Hurried hauling costs 3 less energy.",
            battle="Approach: first damaging hit loses up to 6 harm."},
        release_rope={name="Release rope",price=10,weight=3,icon="water",
            wagon="Basic hit on exposed foe +4; DEF -5",
            travel="Halves food and cargo loss in a bad crossing.",
            battle="Wearer fighting: scavenger retreat loses at most 4 food / 4 cargo."},
        dry_wrap={name="Dry wrap",price=8,weight=2,icon="rest",
            wagon="Any crew shield: +2.5 Focus/s; basic -2",
            travel="With meals in rain: wearer recovers 3 extra energy.",
            battle="Bellmoth keeps its full 16-cover shimmer in rain."},
    },
}
