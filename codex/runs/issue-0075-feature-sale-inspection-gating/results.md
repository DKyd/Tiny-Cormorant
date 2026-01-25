# Results

Summary of changes and rationale:
- Added a deterministic legal-sale inspection gate that mirrors entry checks (pressure bucket ? chance ? deterministic roll), so sales only sometimes trigger Customs.
- Routed legal sale inspections through the new Customs helper instead of always running an inspection.

Files changed (with brief explanation per file):
- `res://singletons/Customs.gd`: added `run_sale_check` helper using pressure bucket + deterministic roll for `SELL_CARGO_LEGAL`.
- `res://singletons/GameState.gd`: legal sale flow now calls `Customs.run_sale_check` instead of unconditional inspection.

Assumptions made:
- Using the same pressure-bucket chance mapping as entry checks is acceptable for legal sale gating.

Known limitations or TODOs:
- No custom chance tuning for legal sales beyond the shared bucket mapping.
