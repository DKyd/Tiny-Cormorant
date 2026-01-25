# Results

Summary of changes and rationale:
- Added deterministic port-departure inspection gating in Customs and wired it to run once when leaving a docked location for inter-system travel.

Files changed (with brief explanation per file):
- `res://singletons/Customs.gd`: added `run_departure_check` using pressure bucket + deterministic roll with action `PORT_DEPARTURE_CLEARANCE`.
- `res://singletons/GameState.gd`: call `Customs.run_departure_check` before travel state changes when departing from a docked location.

Assumptions made:
- Departure checks should run before charging travel cost and before resetting `current_location_id` to preserve the pre-departure tick and docked location.

Known limitations or TODOs:
- None.
