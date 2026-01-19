Summary of refactor
- Added public, query-focused GameState helpers for contract lifecycle checks and destination counts to keep UI and Contracts from reading internal arrays.
- Routed MapPanel and Contracts to the new GameState APIs while preserving existing abandonment filtering and counts.

Files changed
- singletons/GameState.gd: add public contract query helpers (active check, destination ids, destination counts) without exposing mutable state.
- scripts/MapPanel.gd: use GameState query helpers instead of iterating active_contracts directly.
- singletons/Contracts.gd: use GameState.is_contract_active for active checks.

Manual test results
- Not run (not requested).

Behavior unchanged
- Contract acceptance, completion gating, abandonment semantics, and destination counts remain unchanged; only call routing shifted to GameState APIs.

Follow-ups / known gaps
- None.
