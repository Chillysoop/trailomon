# Guardian experiment

2026-10-30: After shipping F1 automatic captures, resumed approved next-1 N3 / combat-1 C2. Implemented opt-in F3 developer encounter "Guardian pattern / developer experiment". Normal road encounters retain their prior random pattern; the experiment is not adopted as the default yet.

Sequence: cargo shove 14, approach warning 0, approach heavy 20, cargo heavy 20. Four-exchange cap, ordinary pressure and 4 energy per exchange remain. Warning spends no defensive ability and cannot trigger Cindercoil's follow-up. Pattern is visible before commitment; save/resume and free back preserve it. Missing pattern keeps old automatic and manual saves playable. No new enemy, region, loot or combat clock.

Evidence: 49 Lua tests, 3 capture isolation checks, native persistence including every new stage and 36 GUI states. Automatic real-render captures inspected for setup, warning, heavy rush and developer menu at 1280x720. Harness now resets exchange-log selection like the production controller. Physical input/audio not claimed.

`./tools/guardian_report.ps1` repeats exact comparison output: 4,800 battles across 30 ordered two-species crews, 20 seeds, meadow/clear and ridge/rain, 100 and 16 starting energy. Rested wins unchanged at 420/1200 per variant; mean cargo harm 13.89 -> 9.33, companion harm 10.58 -> 5.93. Tired wins 0 -> 40/1200, but cargo harm 10.12 -> 12.68 and companion harm 6.95 -> 11.63. Rested improvements are not an overall balance win. Net energy includes detour recovery; companion harm sums direct combat hits. The default crew is not representative of all pairings.

38 matched guardian continuations from 120 reference journeys all completed twice identically. Both variants delivered 11 and arrived late 27; mean ending day 27.66 and recovery days 1.39 unchanged. Identical initial state and downstream policy; only this guardian differs. Broader pacing or optimality is not established. Keep prototype in developer controls until S5 resolves tired-crew costs and readability. Full report and source hashes live in .tools; regenerate with the command above.

Build gotcha: Defold discovered cached extension source under .tools despite Git ignoring it. Added root .defignore and a native assertion that screenshot is absent from the ordinary engine. Defold then cleaned the custom engine and used the stock one; capture mirror still resolves its pinned dependency. Root production configuration remains unchanged.
