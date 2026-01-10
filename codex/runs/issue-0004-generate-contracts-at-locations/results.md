Issue: issue-0004
Title: Per-location contract boards (owned lists) + cargo space payload

Updated contract schema (preserved + new)
- id: String
- origin: String (system id)
- destination: String (system id)
- destination_name: String (system name)
- jumps: int
- reward: float
- cargo_lines: Array of Dictionary
  - commodity_id: String
  - declared_qty: int
  - cargo_space: int
- origin_location_id: String
- origin_location_name: String
- destination_location_id: String
- destination_location_name: String

Per-location list storage
- contracts_by_location_id: Dictionary[String, Array] stored in Contracts singleton.

Cargo space option and rule
- Option A: each cargo line includes cargo_space.
- Rule: cargo_space equals declared_qty at generation; total required space is sum of cargo_space across lines.

Refresh trigger
- Contracts.refresh_contracts_for_location runs from GameState.set_current_location (single authoritative docking path).
- Rationale: ensures stable, per-location boards on each dock without regenerating on every Job Board open.

Files changed
- singletons/Contracts.gd: added per-location storage + get/refresh APIs; added cargo_space to cargo_lines.
- singletons/GameState.gd: refresh contracts on docking; centralizes refresh by routing startup location through set_current_location.
- scripts/JobBoardPanel.gd: Job Board reads per-location list via Contracts.get_contracts_for_location.

Manual test steps
1. Launch the game and dock at Location A.
2. Open Job Board and confirm at least 3 contracts. Verify each has origin_location_id == Location A.
3. Inspect a contract and verify destination location, jumps, reward, cargo_lines with cargo_space.
4. Dock at Location B (different location/system).
5. Open Job Board and confirm list differs and each has origin_location_id == Location B.
6. Return to Location A and confirm its board remains stable per docking refresh.
7. Confirm no errors in the debugger during docking or Job Board open.

Recommended follow-ups
- Add cargo capacity validation when accepting contracts using cargo_space totals.
- Add a soft cap or rotation policy for contracts_by_location_id if boards should expire.
- Hook location context (org/faction) into refresh_contracts_for_location generation.
