# Results

## Summary
- Set inspection preview max depth deterministically from the customs pressure bucket (High -> 2, Low/Elevated -> 1).
- Added a human-readable reason line explaining the max depth decision.

## Files Changed
- `res://singletons/GameState.gd`: compute and return pressure-based `max_depth` and add a max-depth reason in the preview.

## New Public APIs
- None.

## Manual Test Steps
1. Dock at a low-pressure location; open the Port UI and confirm preview shows max depth 1.
2. Increase customs pressure through repeated invalid inspections; confirm preview updates to max depth 2 when threshold is crossed.
3. Trigger a Customs inspection in a max-depth-2 context and confirm Level-2 audit runs and logs.

## Assumptions Made
- Pressure bucket values are the existing strings `Low`, `Elevated`, and `High` as surfaced by `get_customs_pressure_bucket`.

## Known Limitations / Follow-ups
- Depth gating is currently limited to High -> Level 2; no depth 0 path is used.
