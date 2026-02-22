# Results

## Summary of changes and rationale
- Updated Port advisory inspection preview text to explicitly include scrutiny state (`Normal` or `Heightened (+N)`) and final resolved max depth (`L#`) from `GameState.resolve_customs_inspection_depth(...)`.
- Preserved deterministic ordering by composing the preview details in fixed field order and appending resolver `reasons` in array order when available.
- Added safe fallback behavior: if resolver output is not OK, preview remains `Unknown`; malformed reason entries are ignored without errors.

## Files changed
- `scripts/Port.gd`
  - Enhanced `_refresh_header()` preview string composition to include scrutiny state and final max depth.
  - Reused `depth_bias`, `likelihood`, `max_depth`, and optional `reasons` from resolver output.
  - Kept existing header scrutiny line behavior unchanged while making preview line self-contained.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0098-surface-scrutiny-in-inspection-preview`.
- `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/job.md`
  - Added provided job spec.
- `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/results.md`
  - Added this results report.

## Assumptions made
- Displaying `reasons` inline in advisory preview is acceptable as long as ordering remains stable and message remains single-block text.
- Negative `depth_bias` values are treated as invalid and clamped to `0` for display safety.

## Known limitations or TODOs
- Manual Godot runtime verification was not performed in this environment.
- Existing debug `print()` statements in `scripts/Port.gd` predate this change and were left untouched.
