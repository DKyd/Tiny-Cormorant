## Summary of refactor
- Restored API boundary by removing external calls from `GameState` to Customs private `_evaluate_cross_document_invariants(...)`.
- Extended public `Customs.evaluate_level2_cross_document_invariants(...)` to accept an optional precomputed audit and delegate internally to the private evaluator.
- Corrected the 0092 job whitelist note to match landed behavior in `GameState.gd`.

## Files changed
- `singletons/Customs.gd`
  - Updated public API wrapper signature to accept `precomputed_audit` and forward to private evaluator.
- `singletons/GameState.gd`
  - Replaced private-call usage with public API call in `run_customs_inspection()`.
- `codex/runs/issue-0092-feature-level-2-cross-document-invariants/job.md`
  - Corrected whitelist note for `GameState.gd` to reflect inspection-report wiring change.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `refactor-0093-level2-invariant-api-boundary`.
- `codex/runs/refactor-0093-level2-invariant-api-boundary/job.md`
  - Added refactor job specification.
- `codex/runs/refactor-0093-level2-invariant-api-boundary/results.md`
  - Added this refactor summary.

## Manual test results
- Static path verification only (no runtime Godot session executed in this pass).
- Confirmed `run_customs_inspection()` still populates:
  - `level2_audit`
  - `level2_evidence_flags`
  - `invariant_violations`
  using the same `level2_context` and `level2_audit` inputs as before.

## Confirmation behavior is unchanged
- `invariant_violations` payload source remains the same private evaluator and same precomputed audit object.
- No classification, pressure, trigger, or enforcement logic was changed.
- No new randomness, no UI changes, and no state mutation paths added.

## Follow-ups / known gaps (if any)
- Runtime/manual in-engine verification is still recommended to validate report equivalence under live inspection triggers.
