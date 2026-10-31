# Discovery and habits verification

2026-10-31: approved W5/W6 implementation. Actual 1280 by 720 release-renderer captures use isolated scripted production UI fixtures, without player saves or Computer Use.

- `feature-source.json`: Discovery starter/recruit, habits, gathering and paginated developer menu.
- `options-source.json`: depot switch after removing overlapping recent-log text from Options.
- `crew-source.json`: shortened Crew heading beside the new habit control; final game source inputs.

104 Lua scenarios pass, including 64 full Discovery/habit journeys replayed exactly. Native persistence verifies separate save/backup pairs, starter/habit retention, switching back, and reopening the selected depot; 36 existing native GUI states remain green. Screens were inspected for costs, wrapping and overlap. These fixtures do not establish human pacing or optimal balance.
