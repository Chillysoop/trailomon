-- Distances are shared by departure and the report shown before committing.
return {
    [2]={
        {id="meadow", label="Across the meadows", distance=27,
            facts="Open ground; normal terrain speed. First gathering: 10 food before crew help and meals."},
        {id="woodland", label="Through the woodland", distance=30,
            facts="Woodland slows travel by 10%. First gathering: 10 food, the same as the meadow."},
    },
    [5]={
        {id="ridge", label="Take the ridge road", distance=30,
            facts="5% faster terrain; +0.6 wagon wear per travel day. Hurried pace also costs 2 cargo per day."},
        {id="gorge", label="Follow the sheltered gorge", distance=35,
            facts="10% slower terrain; no ridge wear. First gathering: 6 food before crew help and meals."},
    },
}
