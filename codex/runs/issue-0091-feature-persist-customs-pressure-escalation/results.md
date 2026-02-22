## Summary of changes and rationale
- Hardened Customs pressure reads to use a canonical scrutiny-delta source (`customs_scrutiny_delta`) while preserving current pressure formulas and deterministic behavior.
- Added a backward-compatible fallback so older/inconsistent location data that only contains tagged `delta_influences` scrutiny entries still contributes to pressure deterministically.
- Kept this change detection-only and non-enforcement: no penalties, blocking, cargo mutation, or UI changes were introduced.

## Files changed
- `singletons/GameState.gd`
  - Updated `get_customs_pressure(location_id)` to normalize government influence by replacing scrutiny influence from `delta_influences` with scrutiny from the canonical field.
  - Updated `_get_customs_scrutiny_delta_from_location(location)` to fall back to tagged `delta_influences` when the canonical field is missing/non-numeric.
  - Added `_get_customs_scrutiny_delta_from_delta_influences(location)` helper to compute tagged scrutiny deterministically.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0091-feature-persist-customs-pressure-escalation`.
- `codex/runs/issue-0091-feature-persist-customs-pressure-escalation/job.md`
  - Added job specification.
- `codex/runs/issue-0091-feature-persist-customs-pressure-escalation/results.md`
  - Added this results summary.

## Assumptions made
- Existing save/load persistence (`customs_scrutiny_deltas_by_location`) remains the intended persistence channel and does not require schema changes.
- Tagged scrutiny entries in `delta_influences` (`source == customs_scrutiny`) are legacy/secondary and should not be the canonical read source when the field exists.
- Existing inspection gating/preview logic should continue to read from `get_customs_pressure_bucket()` without behavioral restructuring.

## Known limitations or TODOs
- This job does not add pressure decay; persistence now remains stable until changed by existing write paths.
- Verification of save->reload continuity is manual/runtime (no automated tests added in this patch).
