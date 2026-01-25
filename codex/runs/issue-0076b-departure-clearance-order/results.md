# Results

Summary of changes and rationale:
- No code changes needed: `Customs.run_departure_check(...)` already runs after destination validation and the insufficient-credits early return, while `current_location_id` still represents the departure location.

Files changed (with brief explanation per file):
- None.

Assumptions made:
- Current placement in `GameState.travel_to_system` is the correct post-affordability/pre-mutation boundary.

Known limitations or TODOs:
- None.
