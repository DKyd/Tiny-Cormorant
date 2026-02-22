# Results

## Summary of changes and rationale
- Implemented `scripts/customs/CustomsInvariants.gd` as a deterministic Level-2 invariant evaluator returning structured results with `id`, `status`, `severity`, `weight`, `summary`, and `details`.
- Applied policy decision for route checks: `L2INV-002` is now always `not_evaluable` with reason `policy_disabled_no_mandated_routes`, with no origin/destination comparisons.
- Kept quantity (`L2INV-001`) and timestamp (`L2INV-003`) checks deterministic with stable key sorting and explicit `not_evaluable` outcomes when required data is missing.
- Adjusted container-meta logic (`L2INV-004`) to prefer `not_evaluable` when container fields are absent on all relevant docs, fail only on cross-doc completeness mismatch or explicit contradictions.
- Rejected prior out-of-scope integration edits by restoring `singletons/Customs.gd` and `singletons/GameState.gd` to baseline.

## Files changed
- `scripts/customs/CustomsInvariants.gd`
  - Added/updated deterministic invariant evaluation logic for `L2INV-001` through `L2INV-004` per policy.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0100-formalize-level-2-cross-document-invariants`.
- `codex/runs/issue-0100-formalize-level-2-cross-document-invariants/job.md`
  - Saved provided job specification verbatim.
- `codex/runs/issue-0100-formalize-level-2-cross-document-invariants/results.md`
  - Added this implementation summary.

## Assumptions made
- Declaration-like documents remain represented by `declaration` and/or `purchase_order` doc types.
- If `cargo` is absent from context, quantity invariant is intentionally `not_evaluable` (no synthetic data/plumbing added).

## Known limitations / TODOs
- No GameState/Customs integration was changed in this revision by request; runtime consumption of these new invariant statuses depends on existing call paths.
- Route consistency remains intentionally disabled until mandated-route model support exists.
- Container completeness currently evaluates relevant docs as `contract`, `declaration`, `purchase_order`, and `bill_of_sale`.