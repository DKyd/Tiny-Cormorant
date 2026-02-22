# Results

## Summary of refactor
- Centralized inspection depth resolution into one authoritative GameState helper: `resolve_customs_inspection_depth(context)`.
- Kept `get_inspection_preview(context)` as a compatibility wrapper that delegates to the centralized helper.
- Updated Customs runtime depth resolution to call the centralized GameState helper directly, instead of re-deriving from preview fields.
- Preserved existing depth-bias behavior and heightened-scrutiny logging conditions.

## Files changed
- `singletons/GameState.gd`
  - Renamed the prior preview implementation body into `resolve_customs_inspection_depth(context)`.
  - Added `get_inspection_preview(context)` wrapper delegating to the centralized resolver.
- `singletons/Customs.gd`
  - Updated `_resolve_inspection_max_depth(...)` to call `GameState.resolve_customs_inspection_depth(...)`.
  - Removed duplicate local clamping/preview derivation path.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0096-centralize-inspection-max-depth-resolution`.
- `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/job.md`
  - Added provided job spec.
- `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/results.md`
  - Added this report.

## Manual test results
- Not run in Godot in this environment.
- Expected verification paths (entry, departure, sale) remain aligned to existing behavior because all now route through the same resolver.

## Confirmation behavior is unchanged
- Max-depth computation logic and inputs are unchanged; only call-path consolidation was performed.
- Heightened scrutiny log emission still occurs only when `depth_bias > 0` in `_resolve_inspection_max_depth(...)`, once per triggered inspection path.
- No new randomness, timers, UI mutations, or gameplay-side semantics were introduced.

## Follow-ups / known gaps
- None identified in scope.
