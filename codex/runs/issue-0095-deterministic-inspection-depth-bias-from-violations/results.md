# Results

## Summary of changes and rationale
- Added deterministic, bounded "heightened scrutiny" memory in `GameState` keyed by `location_id` as `last_level2_violation_tick` semantics (`location_id -> tick`).
- Updated inspection preview depth selection to apply a capped `depth_bias` (`+1` within a fixed 24-tick window) and clamp final depth deterministically.
- Recorded Level-2 invariant violation outcomes during inspection resolution and fed that memory into the next preview.
- Persisted and restored the new memory field in save/load for deterministic post-reload behavior.
- Added one CUSTOMS log line when a bias is actually applied, with no per-frame behavior.

## Files changed
- `singletons/GameState.gd`
  - Added deterministic violation-memory state, helper methods, save/load persistence, preview bias computation, and violation recording on Level-2 findings.
- `singletons/Customs.gd`
  - Added shared max-depth resolver that consumes preview `depth_bias` and emits a single heightened-scrutiny log when active.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0095-deterministic-inspection-depth-bias-from-violations`.
- `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/job.md`
  - Wrote provided feature job spec verbatim.
- `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/results.md`
  - Recorded this results summary.

## Assumptions made
- A deterministic, bounded tick window (24 ticks) is acceptable for "recent" violation memory.
- `location_id` is the stable key for scrutiny carry-forward.
- Persisting `Dictionary(location_id -> int tick)` satisfies save/load determinism needs without broader schema changes.

## Known limitations / TODOs
- Bias cap is intentionally fixed at `+1` and currently not data-driven.
- Memory uses last-violation tick per location (not multi-event weighted history).
- No automated tests were added in this change set; behavior is validated via manual inspection flow.