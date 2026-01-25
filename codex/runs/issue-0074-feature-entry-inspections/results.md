# Results

## Summary of changes and rationale
- Wired a single deterministic entry inspection attempt on successful inter-system arrival.
- The entry roll occurs after inter-system travel ticks advance so the roll is keyed to the arrival tick and remains reproducible (seeded by `system_id|location_id|action|time_tick`).

## Files changed (with brief explanation per file)
- `res://singletons/GameState.gd`: call `Customs.run_entry_check(new_system_id)` after inter-system travel time advancement.

## Assumptions made
- `Customs.run_entry_check(system_id)` is the authoritative entry-check trigger and should be invoked once per successful system arrival.
- Entry jurisdiction selection is handled by `GameState.get_entry_customs_location_id(system_id)` (highest-pressure location, lexicographic tie-break).

## Known limitations / TODOs
- None.
