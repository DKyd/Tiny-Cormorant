## Summary of Changes and Rationale
- Formalized Level-2 cross-document invariant surfacing as evidence flags via a Customs API: `Customs.evaluate_level2_cross_document_invariants(inspection_ctx)`.
- Kept Level-2 detection deterministic and detection-only by reusing existing snapshot-driven audit logic (`GameState.run_level2_customs_audit`) with no enforcement changes.
- Exposed Level-2 findings explicitly on inspection reports as `level2_evidence_flags` for clear evidence-style consumption without changing gameplay outcomes.

## Files Changed
- `singletons/Customs.gd`
  - Added `evaluate_level2_cross_document_invariants(inspection_ctx: Dictionary) -> Array`.
  - Method delegates to `run_level_2_audit`, extracts structured findings, and returns deep-copied evidence dictionaries.
- `singletons/GameState.gd`
  - Updated `run_customs_inspection()` to publish `report["level2_evidence_flags"]` from Level-2 findings when depth >= 2.
  - No cargo/credits/document mutation behavior was added.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0082-feature-level-2-cross-document-invariants`.
- `codex/runs/issue-0082-feature-level-2-cross-document-invariants/job.md`
  - Added job specification verbatim.
- `codex/runs/issue-0082-feature-level-2-cross-document-invariants/results.md`
  - Added this run summary.

## Assumptions Made
- Existing Level-2 invariant evaluation in `GameState.run_level2_customs_audit()` is the canonical deterministic implementation for this codebase.
- Existing logging in `_format_customs_log_entry()` and Level-2 summary formatting is sufficient for clear human-readable output without UI additions.
- The requested API can return `Array` in GDScript while still carrying Dictionary evidence entries.

## Known Limitations / TODOs
- `Customs.evaluate_level2_cross_document_invariants()` is currently an API surface and is not separately invoked by the main inspection path (which already runs Level-2 in `GameState.run_customs_inspection()`).
- No new test harness was added in this change; verification remains via runtime inspection/log behavior per manual test plan.
