## Summary of Changes and Rationale
Implemented Level 2 purity for `L2INV-001` by policy-disabling cargo-snapshot reconciliation in Level 2. The quantity-consistency invariant now returns deterministic `not_evaluable` with reason `policy_disabled_until_level3` instead of reading runtime cargo and potentially failing INVALID. This enforces documentary-only behavior at Level 2 and defers cargo reconciliation to Level 3.

## Files Changed
- `scripts/customs/CustomsInvariants.gd`
  - `evaluate(...)` no longer extracts/uses cargo snapshot for L2INV-001.
  - Replaced quantity check function with ` _evaluate_quantity_consistency_policy_disabled_until_level3(docs_by_id)`.
  - Added explicit policy boundary comment: L2INV-001 is disabled at Level 2 and reserved for Level 3 cargo reconciliation.
  - Removed unused `_extract_cargo_snapshot(...)` helper.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0111-l2-purity-disable-cargo-snapshot`.
- `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/job.md`
  - Added job record.
- `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/results.md`
  - Added this implementation summary.

## Assumptions Made
- Level 2 policy now intentionally excludes runtime cargo reconciliation entirely.
- `policy_disabled_until_level3` is the canonical not-evaluable reason for L2INV-001 in this phase.
- Existing Level 2 classification logic should treat `not_evaluable` invariants as non-failing (unchanged behavior in `CustomsLevel2Audit.gd`).

## Known Limitations / TODOs
- Manual Godot runtime verification is still required for end-to-end confirmation in live inspection flows.
- This change removes Level 2 signal from cargo mismatch scenarios by design; those checks must be implemented at Level 3.