# Results

## Summary of changes and rationale
- Added a read-only Port header line that surfaces current Customs scrutiny state from deterministic depth resolution: `Customs scrutiny: Normal` or `Customs scrutiny: Heightened (+N depth)`.
- Sourced the display from `GameState.resolve_customs_inspection_depth({system_id, location_id})` so UI reuses authoritative depth-bias output and does not duplicate rules.
- Added safe fallback behavior for missing/invalid context by showing `Customs scrutiny: Unknown`.

## Files changed
- `scripts/Port.gd`
  - Updated `_refresh_header()` to call `GameState.resolve_customs_inspection_depth(...)`.
  - Added deterministic scrutiny line formatting from `depth_bias`.
  - Added unknown-system fallback line for scrutiny.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0097-surface-scrutiny-depth-bias-port-header`.
- `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/job.md`
  - Added provided feature job spec.
- `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/results.md`
  - Added this report.

## Assumptions made
- Casting numeric `depth_bias` values to `int` is acceptable for display and malformed/non-numeric values should be treated as `0` (Normal).
- Existing Port header multi-line layout can accept one additional short line without UI overflow issues in typical viewport sizes.

## Known limitations or TODOs
- Manual Godot runtime verification was not executed in this environment.
- Existing debug `print()` lines in `Port.gd` were left unchanged because they pre-existed and are outside this feature’s scope.
