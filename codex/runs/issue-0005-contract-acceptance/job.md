# Feature Job

## Metadata
- Issue/Task ID: feature-0005
- Short Title: Contract Acceptance (Freight Docs, Cargo Load, Active Contracts)
- Author (human): Douglass
- Date: 2026-01

---

## Goal
Enable players to accept contracts while docked, resulting in a recorded freight document, reserved ship cargo, and the contract becoming active.  
Acceptance must be validated against location and cargo capacity and must centralize all side effects.

---

## Non-Goals
This job must NOT:
- Implement contract expiration or lifecycle policies
- Rename or normalize existing contract schema fields
- Support partial, staged, or delayed cargo loading
- Purchase cargo from markets
- Redesign UI or introduce new UI panels
- Refactor unrelated systems

---

## Context
- GameState is authoritative for current system, location, and docking.
- `GameState.set_current_location()` is the single authoritative docking path.
- Contracts are owned per origin location:
  - `Contracts.contracts_by_location_id: Dictionary[String, Array]`
  - `Contracts.refresh_contracts_for_location(location_id, count)` runs once per dock
  - Job boards are read-only and never regenerate contracts
- UI must not own or mutate game state.
- Logging is centralized via `Log.add_entry(text)`.
- Cargo rules:
  - `cargo_space == declared_qty` per cargo line
  - Total cargo required = sum of `cargo_space`

Existing systems already support:
- Contract generation and per-location boards
- Docking and location changes
- Logging
- Ship representation (cargo system may be partial or absent)

This job fills the missing “accept contract” path.

---

## Proposed Approach
- Extend the existing Contracts system to support acceptance
- Validate acceptance against dock state and cargo capacity
- Record acceptance side effects centrally
- Remove accepted contracts from origin boards
- Wire UI to call a single authoritative acceptance API

---

## Files: Allowed to Modify (Whitelist)
- `singletons/Contracts.gd`
- `singletons/GameState.gd` (only if needed for dock state access)
- Ship / cargo / inventory scripts (existing only)
- Job board UI scripts responsible for acceptance input

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`
- Any unrelated singletons or UI roots

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
- Add or extend an authoritative contract acceptance API on `Contracts`
  - Example: `accept_contract(contract_id: String) -> Dictionary`
- No other public APIs should be added or modified.

---

## Acceptance Criteria (Must Be Testable)
- [ ] A contract can only be accepted while docked at its origin location
- [ ] Acceptance fails cleanly if the player is not docked or docked elsewhere
- [ ] Acceptance fails if the contract is missing or already active
- [ ] Acceptance fails if ship cargo capacity is insufficient
- [ ] On success, a freight document is created exactly once
- [ ] On success, ship cargo usage increases by total required cargo space
- [ ] On success, the contract is removed from the origin board
- [ ] On success, the contract appears in the active contracts list
- [ ] UI does not directly mutate game state
- [ ] Success and failure are logged via `Log.add_entry`

---

## Manual Test Plan
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

---

## Edge Cases / Failure Modes
- Accepting a contract during an invalid dock state
- Duplicate acceptance attempts
- Partial side effects if validation fails
- Board refresh accidentally resurrecting accepted contracts

---

## Risks / Notes
- Care must be taken to keep acceptance atomic (no partial mutations)
- Ship cargo systems may be incomplete or minimal
- Contract acceptance must not introduce a second side-effect path

---

## Codex Output Requirements
Codex must write results **only** to:
- `codex/runs/feature-0005-contract-acceptance/results.md`

Results must include:
- Summary of changes and rationale
- Files changed with brief explanation per file
- Assumptions made during implementation
- Known limitations or TODOs
