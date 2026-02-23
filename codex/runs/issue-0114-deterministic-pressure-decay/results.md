## Summary of Changes and Rationale
- Added deterministic customs scrutiny decay tied to `advance_time` tick progression.
- Decay now applies to existing persisted per-location scrutiny deltas (`customs_scrutiny_delta`) with stable constants and clamping.
- Hook uses `tick_delta` derived in `advance_time` (not a hardcoded decay call literal), preserving deterministic behavior if tick increment logic changes later.

## Files Changed
- `singletons/GameState.gd`
  - Added `CUSTOMS_SCRUTINY_DECAY_PER_TICK` tuning constant.
  - Added `_apply_customs_scrutiny_decay(tick_delta)` internal function.
  - Updated `advance_time(reason)` to derive `tick_delta`, increment `time_tick` by that delta, and apply scrutiny decay after tick update.
- `codex/runs/issue-0114-deterministic-pressure-decay/job.md`
  - Captured this issue’s feature job text.
- `codex/runs/issue-0114-deterministic-pressure-decay/results.md`
  - Recorded implementation outcomes and assumptions.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0114-deterministic-pressure-decay`.

## Assumptions Made
- Canonical stored pressure input is the per-location `customs_scrutiny_delta` field (with mirrored `delta_influences` entry maintained by `_set_customs_scrutiny_delta_for_location`).
- Decay should be applied on each `advance_time` tick, and this is the single deterministic integration point.

## Known Limitations or TODOs
- No manual in-Godot validation was run in this session.
- Decay tuning constant is conservative (`0.005` per tick) and may require gameplay tuning.
- This change intentionally does not alter inspection chance formulas, bucket thresholds, or inspection trigger paths.
