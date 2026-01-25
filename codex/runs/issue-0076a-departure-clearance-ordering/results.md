# Results

Summary of changes and rationale:
- Registered `PORT_DEPARTURE_CLEARANCE` in `SURFACE_ACTION_REQUIREMENTS` so departure inspections are not flagged as unsupported.
- Confirmed departure clearance is invoked after affordability checks and before travel state mutation, preserving the pre-departure tick and location context.

Files changed (with brief explanation per file):
- `res://singletons/GameState.gd`: added `PORT_DEPARTURE_CLEARANCE` to action requirements (departure check ordering already aligned with requirements).

Assumptions made:
- Existing departure check placement in `travel_to_system` is the correct post-affordability/pre-mutation boundary.

Known limitations or TODOs:
- None.

Intentional design constraints (do not regress):
- `PORT_DEPARTURE_CLEARANCE` must remain a first-class Surface Compliance action in `SURFACE_ACTION_REQUIREMENTS`, with the same semantics (requires cargo present and any-of doc types: purchase_order OR contract).
- Departure clearance trigger ordering is deliberate: run only after affordability checks, before any travel state mutation that would lose departure context, and never when `current_location_id == ""`.
- Determinism guardrail: departure checks must use `GameState.roll_customs_inspection(system_id, location_id, "PORT_DEPARTURE_CLEARANCE", chance)` (pressure bucket → chance → deterministic roll). Randomness affects whether a check occurs, never inspection outcome logic.
