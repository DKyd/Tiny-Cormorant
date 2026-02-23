## Summary of Changes and Rationale
- Added deterministic issuer metadata insertion for newly created `contract`, `purchase_order`, and `bill_of_sale` documents in `GameState.gd`.
- Added Level 1 issuer-field validation in `CustomsLevel1Audit.gd` for `purchase_order`, `bill_of_sale`, and `contract` docs.
- Level 1 now reports `FAIL`/`INVALID` (`L1CHK-007` with finding `L1F-007`) when `issuer_org_id` or `issuer_marker` is missing/empty.

## Files Changed
- `singletons/GameState.gd`
  - Added issuer helpers:
    - `_resolve_issuer_org_id_for_doc(market_kind)`
    - `_build_issuer_marker(doc_type, issuer_org_id)`
  - Updated doc creation paths to set issuer fields at creation time and reuse one computed `issuer_org_id` per created doc.
  - Issuer org now derives from market kind where available (`legal -> government`, `black_market -> cartel`).
- `scripts/customs/CustomsLevel1Audit.gd`
  - Added issuer check and finding identifiers:
    - `L1CHK-007`, `L1F-007`
  - Added issuer-target doc collection and issuer-field issue collection for doc types:
    - `purchase_order`, `bill_of_sale`, `contract`
  - Findings include stable details (`doc_id`, normalized `doc_type`, `missing_fields`, plus `system_id`/`location_id` when present in context).
- `codex/runs/issue-0112-phase-a-issuer-markers-level1/job.md`
  - Job spec captured.
- `codex/runs/issue-0112-phase-a-issuer-markers-level1/results.md`
  - This results record.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0112-phase-a-issuer-markers-level1`.

## Assumptions Made
- Level 1 context for docs is the normalized `docs_by_id` dictionary shape already used by existing Level 1 checks.
- Contract docs may include `market_kind`; when absent, contract issuer assignment defaults deterministically to legal (`government`).
- Existing Level 1 classification behavior remains unchanged: any `invalid` finding yields `invalid` classification.

## Known Limitations / TODOs
- Manual in-engine verification has not been run in this session.
- Existing older docs without issuer fields will now fail Level 1 issuer checks as intended.
- This change does not implement any enforcement or migration; it only reports findings and sets fields on newly created docs.
