# Feature Job

## Metadata
- Issue/Task ID: issue-0006
- Short Title: Contract completion (location-specific)
- Author (human): Douglass Kyd
- Date: 2026-01-10

---

## Goal
Travel contracts should complete only when the player docks at the correct destination location, not when entering a destination system. On completion, the system must remove the contract cargo, mark the freight document completed, and pay the contract reward.

---

## Non-Goals
- Do NOT complete contracts on system entry.
- Do NOT change contract acceptance behavior (issue-0005).
- Do NOT add partial delivery, partial unloading, or market purchase flows.
- Do NOT refactor unrelated systems or reorganize files.
- Do NOT modify `data/**`.
- Do NOT modify `scenes/MainGame.tscn` unless explicitly required and whitelisted (assume forbidden).

---

## Context
- `GameState` is authoritative for docking and location changes; `GameState.set_current_location()` is the only authoritative docking path.
- Contract acceptance is centralized/atomic by precondition: UI calls `Contracts.accept_contract(contract_id)`, then `GameState.accept_contract(contract)` performs side effects (active contract, freight doc, cargo load/reserve).
- Contract boards are per origin location and refresh once per dock via `GameState.set_current_location()`.
- There is an existing `check_travel_contracts_at(system_id, location_id)` that needs to be rewritten so completion is docking-based and location-specific.
- Missing/incorrect behavior today: completion triggers on system entry (or is not location-specific).

---

## Proposed Approach
- Ensure contract completion checks are invoked only on docking (via `GameState.set_current_location()`).
- Rewrite `check_travel_contracts_at(system_id, location_id)` to require both destination system and destination location match.
- When a contract completes, perform completion side effects atomically in authoritative systems:
  - remove contract cargo from ship cargo
  - mark freight document completed
  - award credits
  - mark contract completed / remove from active
  - log completion via `Log.add_entry`
- Keep changes minimal and scoped to completion behavior.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Contracts.gd`
- `singletons/Log.gd` (only if needed for completion messaging consistency)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- Any file not listed in the whitelist

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- Modify behavior/signature expectations of: `check_travel_contracts_at(system_id, location_id)` (rewrite logic; keep signature unless already different)
- None otherwise

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Entering a destination system without docking does NOT complete the contract.
- [ ] Docking at a non-destination location (even within the destination system) does NOT complete the contract.
- [ ] Docking at the exact destination location completes the contract: contract cargo is removed, freight doc is marked completed, reward is paid, and a log entry is created.
- [ ] Completion is idempotent: re-docking does not double-pay or re-complete.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a game where at least one travel contract exists from an origin location to a destination location.
2. Dock at the origin location and accept the contract. Confirm cargo capacity is reduced / cargo is loaded/reserved per issue-0005 behavior.
3. Travel to the destination system, but do not dock at the destination location yet. Verify the contract is still active and no completion log/reward occurs.
4. Dock at a different location in the destination system (if available). Verify the contract still does not complete.
5. Dock at the contract’s destination location. Verify:
   - contract cargo is removed
   - freight document is marked completed
   - credits increase by the contract reward
   - contract is no longer active
   - a completion log entry appears
6. Dock at the destination location again. Verify no duplicate reward and no duplicate completion.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Multiple active contracts share the same destination location: all matching contracts complete on docking without errors.
- Contract is already completed (or not active): completion check does nothing (no double-pay).
- If cargo removal cannot be performed (unexpected state), completion must not pay reward or mark completed; it should log an error.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
or architectural concerns.

- Docking flow is central; changing completion triggers must not interfere with board refresh behavior.
- Cargo removal must mirror whatever structure is used by acceptance loading/reservation to avoid desync.
- Completion side effects should remain authoritative (GameState) and UI should remain reactive only.

---

## Codex Output Requirements
Codex must write results to:

- `codex/runs/<job>/results.md`

If `results.md` does not exist, Codex is permitted to create it.
No other new files may be created.

Results must include:
- Summary of changes and rationale
- Files changed with brief explanation per file
- Assumptions made
- Known limitations or TODOs
