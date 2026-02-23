## Summary of Refactor
Deprecated the legacy `GameState.run_level2_customs_audit()` implementation and converted it into a compatibility shim that delegates to the canonical Level 2 audit path: `Customs.run_level_2_audit()`. This removes duplicate audit logic and keeps a single source of truth for Level 2 behavior.

## Files Changed
- `singletons/GameState.gd`
  - Replaced the legacy inlined Level 2 audit engine body with a clearly marked `LEGACY/UNUSED` bridge.
  - Bridge now calls `Customs.run_level_2_audit(context)` and returns a deterministic compatibility-shaped payload (`ok`, `classification`, `reasons`, `findings`).
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0110-refactor-deprecate-legacy-level2-audit`.
- `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/job.md`
  - Added this job record.
- `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/results.md`
  - Added this refactor result summary.

## Manual Test Results
- Not executed in this terminal-only pass (Godot runtime/manual UI verification pending).
- Static verification completed:
  - Active runtime Level 2 path remains `GameState.run_customs_inspection()` -> `Customs.run_level_2_audit(...)`.
  - Repo code search shows no live callers of `run_level2_customs_audit` (definition only).

## Behavior Unchanged Confirmation
- No audit trigger flow changes were made (sale/entry/departure inspection flow unchanged).
- No invariant logic or classification logic was modified in canonical Level 2 audit code.
- Refactor is structural: duplicate legacy implementation removed in favor of delegating to the already-active canonical path.

## Follow-ups / Known Gaps
- Optional future cleanup: remove `run_level2_customs_audit()` entirely once any external/tooling dependence on its compatibility shape is confirmed absent.