Summary of changes and rationale
- Added a read-only "Customs pressure" indicator derived from existing state (security level + freight doc evidence/authenticity), with no enforcement actions.

Files changed
- singletons/GameState.gd: added `get_customs_pressure_bucket(context: Dictionary = {}) -> String` as a read-only query helper.

Public API changes
- New read-only query: `GameState.get_customs_pressure_bucket(...)`.

Assumptions made
- `Galaxy.get_system(system_id)` returns a dictionary containing `security_level`.
- `freight_docs` is available and evidence flags/threshold are stable.

Known limitations / TODOs
- Indicator is perception-only; no inspections are triggered.
- Buckets are coarse and may need tuning later.
- This run adds the query helper only; UI surfacing should be implemented in a separate, UI-scoped run to preserve audit clarity.
