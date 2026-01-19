Summary of changes and rationale
- Added contract abandonment marking when a destroyed FreightDoc is a contract tied to an active contract, ensuring destroyed paperwork blocks completion without affecting cargo.

Files changed (with brief explanation per file)
- singletons/GameState.gd: mark contract as abandoned when its contract FreightDoc is destroyed; relies on existing idempotent abandonment logic.

Assumptions made
- Contract FreightDocs always use doc_type "contract" and store contract_id when they map to active contracts.
- The existing abandonment tracking and completion blocking logic remain correct and do not require additional persistence.

Known limitations or TODOs
- Abandonment is runtime-only and resets on load; persistence is deferred as noted in the job.
