# Minimal-text follow-up

October 31, 2026. Shortened depot, camp and gathering copy; replaced the travel paragraph with compact icon/value readings; retained only the latest road note on the road screen; removed repeated ability descriptions from live combat. Setup still explains abilities and costs, and the full journal remains available. Warnings, eligibility, condition/energy readings and action labels remain visible.

90 Lua scenarios and native save/load, 36 GUI states and all existing interaction checks passed. Seven actual 1280x720 screens inspected: preparation, three-member travel, combat setup, active combat, combat result, gathering and camp. Five representative images are retained here with the capture input manifest. No simulation rules changed.

The native harness had two consecutive redraws without a frame boundary when returning from combat then opening the next fixture. Adding daily icons exposed Defold's deferred-node-deletion limit. A yield now separates those existing checks, matching production's coalesced rendering; the node cap and all assertions are unchanged. Physical input and audio were not retested.
