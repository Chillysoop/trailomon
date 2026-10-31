-- Costs are data shared by the choice preview, validation, and resolution.
return {
 {id="mud", title="A wheel in the mud", text="Recent rain has softened the trail. The wagon settles into a deep rut.", kind="choice", condition="mud",
  choices={
   {id="brace", label="Ask Brindlehorn to brace", species="brindlehorn", effort=18, effects={wagon=-2}, memory="Braced the wagon in the mud."},
   {id="dig", label="Let Loamling clear the rut", species="loamling", effort=16, effects={wagon=-3}},
   {id="boards", label="Lay repair boards under the wheel", cost={repairs=1}},
   {id="wait", label="Unload and pull it clear", days=1, effects={traveler=-3}}}},
 {id="axle", title="A worrying creak", text="The axle has worked loose under the load. The next rough stretch could make it worse.", kind="choice", condition="worn",
  choices={
   {id="fix", label="Fit a spare brace", cost={repairs=1}, effects={wagon=12}, outcome="The new brace holds. The axle turns quietly again."},
   {id="anchor", label="Have Slatewhorl steady a field repair", species="slatewhorl", effort=15, effects={wagon=8}},
   {id="slow", label="Take a day to refit the axle", days=1, effects={wagon=6}},
   {id="risk", label="Lash it and carry on", effects={wagon=-6}, flag="axle_lashed", hint="Another -6 wagon on rough travel; repair prevents it.", outcome="The temporary lashing holds for now. A proper repair will prevent it slipping later."}}},
 {id="damp", title="Damp provisions", text="Rain has found its way into a food sack. A little attention now can save most of it.", kind="choice", condition="rain",
  choices={
   {id="warm", label="Ask Cindercoil to dry the sacks", species="cindercoil", effort=15, cost={food=2}},
   {id="dry", label="Stop and dry everything", days=1},
   {id="discard", label="Discard the spoiled portion", effects={food=-8}}}},
 {id="cold", title="A cold campsite", text="The evening turns sharp. Your companions gather close to the wagon.", kind="choice", condition="cold",
  choices={
   {id="warm", label="Share Cindercoil's stored warmth", species="cindercoil", effort=16, cost={food=2}, effects={stamina=8}},
   {id="supper", label="Make an extra warm supper", cost={food=6}, effects={stamina=6}},
   {id="huddle", label="Huddle under the blankets", effects={traveler=-5, stamina=-8}}}},
 {id="tree", title="A tree across the road", text="A fallen trunk blocks the track. There is room to work, or a longer path around.", kind="choice", condition="woods",
  choices={
   {id="haul", label="Have Brindlehorn shift the trunk", species="brindlehorn", effort=20, flag="road_cleared", hint="Leaves the road clear for travelers behind you."},
   {id="scout", label="Follow Bellmoth's smaller trail", species="bellmoth", effort=14, effects={wagon=-3}},
   {id="detour", label="Take the long way around", days=1}}},
 {id="roots", title="A tempting root patch", text="Fresh shoots mark a patch of edible roots. Gathering them will take a day.", kind="choice", condition="soft",
  choices={
   {id="dig", label="Gather with Loamling", species="loamling", effort=18, days=1, effects={food=18}},
   {id="gather", label="Gather by hand", days=1, effects={food=9}},
   {id="leave", label="Leave the patch for another traveler"}}},
 {id="traveler", title="Someone beside the road", text="A traveler has run short of food. The next settlement is still a long walk away.", kind="choice", condition="any",
  choices={
   {id="share", label="Share a few meals", cost={food=5}, flag="helped_traveler", memory="Shared supper with a stranded traveler."},
   {id="coin", label="Give them ferry money", cost={coins=6}, flag="helped_traveler"},
   {id="directions", label="Offer directions and continue"}}},
 {id="shortcut", title="The disputed shortcut", text="Two weathered signs disagree. A narrow trail seems to rejoin the road ahead.", kind="choice", condition="any",
  choices={
   {id="scout", label="Send Bellmoth to find the markers", species="bellmoth", effort=16, effects={progress=5}},
   {id="risk", label="Try the short trail", gamble=true},
   {id="road", label="Stay on the known road"}}},
 {id="grazing", title="Quiet grazing", text="Your companions find a sheltered patch of grass. For a while, all you hear is chewing.", kind="ambient", condition="soft", effects={stamina=3}},
 {id="shade", title="Shared shade", text="A broad tree offers a little shade. Your wagon rolls through its cool shadow.", kind="ambient", condition="any"},
 {id="calls", title="Distant calls", text="Something answers a call from far beyond the trail. Your companions pause to listen.", kind="ambient", condition="any"},
 {id="play", title="A moment of play", text="A windblown leaf becomes a very important chase. The road feels shorter afterward.", kind="ambient", condition="any"},
 {id="cinder_shelter", title="Warmth beneath the stones", text="A small shelter holds a frightened Cindercoil. Its nest has been soaked through.", kind="discovery", condition="cinder_lead",
  choices={
   {id="help", label="Leave medicine and dry bedding", cost={medicine=1}, flag="cinder_helped", discovery="cindercoil", outcome="The Cindercoil settles into the dry bedding. Its trembling eases."},
   {id="observe", label="Record the shelter and move on", discovery="cindercoil"}}},
 {id="cinder_return", title="A little ember follows", text="The Cindercoil you helped has followed your wheel tracks. It curls beside the wagon as if waiting for an invitation.", kind="discovery", condition="cinder_follow",
  choices={
   {id="invite", label="Invite Cindercoil to join", cost={food=4}, recruit="cindercoil"},
   {id="part", label="Share a goodbye and let it roam"}}},
 {id="slate_tracks", title="Tracks in loose shale", text="A Slatewhorl is wedged among slipped stones. It has been trying to turn itself free.", kind="discovery", condition="slate_lead",
  choices={
   {id="lever", label="Use a repair board as a lever", cost={repairs=1}, flag="slate_helped", discovery="slatewhorl"},
   {id="help", label="Clear a way by hand", days=1, flag="slate_helped", discovery="slatewhorl"},
   {id="observe", label="Record the tracks and continue", discovery="slatewhorl"}}},
 {id="slate_return", title="A patient traveling companion", text="The Slatewhorl you freed has caught up. It rests one broad plate against your wheel, steadying the wagon.", kind="discovery", condition="slate_follow",
  choices={
   {id="invite", label="Make room for Slatewhorl", cost={food=4}, recruit="slatewhorl"},
   {id="part", label="Thank it and leave it on its home trail"}}},
 {id="scavengers", title="Visitors at the wagon", text="Hungry Loamlings circle the provisions. You can leave them a meal, distract them, or defend the load.", kind="encounter", condition="any",
  choices={
   {id="food", label="Leave food away from the wagon", cost={food=6}, outcome="The Loamlings gather around the meal, leaving the wagon a clear path."},
   {id="distract", label="Let Bellmoth lead them away", species="bellmoth", effort=18},
   {id="battle", label="Protect the cargo", battle="scavengers"}}},
 {id="territorial", title="The narrow path", text="A wild Slatewhorl blocks the track, unsettled by your approach. Give it space or persuade it to move.", kind="encounter", condition="upland",
  choices={
   {id="wait", label="Wait for it to wander away", days=1},
   {id="calm", label="Let Reedskipper draw it aside", species="reedskipper", effort=18},
   {id="battle", label="Secure passage", battle="territorial"}}},
 {id="wild_brindlehorn",title="A call across the meadow",text="A Brindlehorn herd answers through hollow antlers. One youngster noses a caught feed sack.",kind="wildlife",condition="wild_meadow",
  choices={{id="watch",label="Watch the herd",observe="brindlehorn",outcome="You record the herd's answering calls."},
   {id="help",label="Leave a meal clear of the road",cost={food=2},observe="brindlehorn",outcome="The youngster follows the meal back toward the herd."},
   {id="pass",label="Pass quietly"}}},
 {id="wild_bellmoth",title="Wings beneath the shelter",text="Bellmoths fold beneath a woodland roof. A loose board lets rain reach their roost.",kind="wildlife",condition="wild_woods",
  choices={{id="watch",label="Watch the roost",observe="bellmoth",outcome="You record how Bellmoths shelter their reflective wings."},
   {id="help",label="Patch the loose board",cost={repairs=1},observe="bellmoth",outcome="The board holds. The folded wings stay dry."},
   {id="pass",label="Pass quietly"}}},
 {id="wild_reedskipper",title="A platform in the reeds",text="A Reedskipper draws stems onto a floating bed beside the shallow river margin.",kind="wildlife",condition="wild_river",
  choices={{id="watch",label="Watch the shallows",observe="reedskipper",outcome="You record the resting platforms along the shallow margin."},
   {id="help",label="Leave food on the bank",cost={food=2},observe="reedskipper",outcome="The Reedskipper takes a meal, then returns to its platform."},
   {id="pass",label="Pass quietly"}}},
}
