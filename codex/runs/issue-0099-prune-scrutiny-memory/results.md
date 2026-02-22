# Results

## Summary of refactor
- Added internal deterministic pruning for `customs_recent_level2_violation_tick_by_location` to remove stale and invalid entries safely.
- Pruning now runs only at two non-frame choke points:
  - `resolve_customs_inspection_depth(...)` before depth-bias computation.
  - `_get_customs_recent_level2_violation_ticks_by_location()` before save serialization.
- Pruning rules applied:
  - Remove empty/invalid location keys.
  - Remove unknown locations.
  - Remove non-int tick values.
  - Remove entries older than `CUSTOMS_LEVEL2_VIOLATION_WINDOW_TICKS` relative to current tick.

## Files changed
- `singletons/GameState.gd`
  - Added `_prune_customs_recent_level2_violation_ticks(current_tick)` helper.
  - Invoked pruning in `resolve_customs_inspection_depth(...)` before bias resolution.
  - Invoked pruning in `_get_customs_recent_level2_violation_ticks_by_location()` before save payload collection.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0099-prune-scrutiny-memory`.
- `codex/runs/issue-0099-prune-scrutiny-memory/job.md`
  - Wrote provided refactor job content.
- `codex/runs/issue-0099-prune-scrutiny-memory/results.md`
  - Added this report.

## Manual test results
- Not executed in Godot in this environment.

## Confirmation behavior is unchanged
- Active bias behavior remains unchanged for entries within the existing window.
- No constants or bias/clamp rules were changed.
- No trigger/audit/classification/pressure logic was changed.
- No new time advancement paths or UI-side state mutation were introduced.

## Follow-ups / known gaps
- No deterministic cap was added because stale/invalid pruning already bounds effective memory by the active window semantics.
