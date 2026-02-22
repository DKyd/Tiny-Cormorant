## Summary of changes and rationale
- Added a dedicated Customs Level-2 invariant evaluator path via `_evaluate_cross_document_invariants()` and kept it detection-only.
- Wired Level-2 inspection resolution to use Customs as the cross-document evaluation entry point after Phase-1, without changing classification semantics.
- Extended inspection report payload with `invariant_violations` so invariant contradictions are explicitly available as structured output.

## Files changed
- `singletons/Customs.gd`
  - Added private `_evaluate_cross_document_invariants(inspection_ctx, precomputed_audit)` to return deep-copied structured findings.
  - Kept public `evaluate_level2_cross_document_invariants()` as a wrapper.
- `singletons/GameState.gd`
  - In `run_customs_inspection()`, switched Level-2 audit call to `Customs.run_level_2_audit(...)`.
  - Added `report["invariant_violations"]` using `Customs._evaluate_cross_document_invariants(...)` with precomputed audit to avoid re-running logic.
  - Preserved existing `level2_audit`, `level2_evidence_flags`, and pressure escalation behavior.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `feature-0092-level-2-cross-document-invariants`.
- `codex/runs/feature-0092-level-2-cross-document-invariants/job.md`
  - Added job spec verbatim.
- `codex/runs/feature-0092-level-2-cross-document-invariants/results.md`
  - Added this result summary.

## Assumptions made
- Existing `GameState.run_level2_customs_audit()` is the canonical deterministic invariant engine and should remain the source of audit semantics.
- Existing CUSTOMS log formatting already surfaces invariant violations through Level-2 snippets and does not require extra log-line fanout.

## Known limitations or TODOs
- No new invariant rules were added; this change centralizes and exposes existing Level-2 findings.
- `invariant_violations` currently mirrors Level-2 findings; consumers should treat it as detection-only metadata.
