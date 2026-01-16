Summary of Refactor
- Added centralized container_meta initialization for contract and market-created FreightDocs to standardize container provenance at creation time.

Files Changed
- singletons/GameState.gd

Manual Test Results
- Not run (manual).

Behavior Unchanged Confirmation
- Container metadata defaults are set only at creation and do not alter existing edit or delivery flows.

Follow-ups / Known Gaps
- None noted.
