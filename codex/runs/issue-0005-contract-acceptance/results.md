# Results - issue-0005-contract-acceptance

## Summary
- Centralized contract acceptance through `Contracts.accept_contract`, which validates docking, availability, active status, and cargo capacity before delegating to a single GameState side-effect path.
- Added an authoritative `GameState.accept_contract` that validates origin/dock and capacity, then applies the acceptance side effects in one place.
- Job board UI now calls the Contracts acceptance API; Contracts removes accepted contracts from the origin board on success.
- Freight documents are created via `GameState.create_freight_doc_for_contract` and retrievable via `GameState.get_docs_for_contract`.

## Files Changed
- `singletons/Contracts.gd`: Added `accept_contract` and helper lookups to validate and remove board contracts, and to call the GameState acceptance path.
- `singletons/GameState.gd`: Added cargo capacity query, acceptance validation, and a consolidated acceptance side-effect method.
- `scripts/JobBoardPanel.gd`: Routed UI acceptance through Contracts and handled success/failure messaging.

## New Public APIs
- `singletons/Contracts.gd`: `accept_contract(contract_id: String) -> Dictionary`
- `singletons/GameState.gd`: `accept_contract(contract: Dictionary) -> Dictionary`
- `singletons/GameState.gd`: `get_free_cargo_space() -> float`

## Manual Test Steps
1. Dock at a location with available contracts.
2. Accept a contract with sufficient free cargo space.
3. Verify:
   - Contract disappears from the board
   - Contract appears as active
   - Freight document exists
   - Cargo space is consumed
4. Attempt to accept the same contract again.
5. Dock at a different location and attempt acceptance.
6. Fill ship cargo, then attempt acceptance again.
7. Dock again to trigger board refresh and verify accepted contracts do not reappear.

Manual tests performed: Not run (sandboxed).

## Assumptions Made
- `add_contract`, `create_freight_doc_for_contract`, and `load_contract_cargo` are assumed non-failing; acceptance preconditions guard against invalid input so acceptance is treated as atomic without rollback.
- Cargo capacity uses weight-based capacity (`cargo_capacity_weight` minus `get_total_cargo_weight()`), while contract required cargo uses `cargo_lines[].cargo_space` (falling back to `declared_qty` or legacy `quantity`).

## Known Limitations / Follow-ups
- If future implementations introduce failure modes in acceptance side-effects, a rollback strategy will be needed to preserve atomicity.
