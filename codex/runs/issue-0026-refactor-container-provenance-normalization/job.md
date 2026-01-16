# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0026
- Short Title: Normalize Container Metadata on Freight Creation
- Run Folder Name: issue-0026-refactor-container-provenance-normalization
- Job Type: refactor
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Normalize how container metadata is initialized when FreightDocs and cargo are created so that contract freight and market-purchased freight have consistent, structured container provenance. This establishes a reliable baseline for future inspection logic without changing gameplay behavior.

---

## Non-Goals
- No gameplay changes.
- No new inspections, penalties, or enforcement.
- No new player-facing UI.
- No persistence format changes.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for state transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Freight ownership, quantities, and delivery semantics remain unchanged.

---

## Scope

### Files Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `singletons/Contracts.gd`
- `singletons/Economy.gd`

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Identify all code paths that create FreightDocs and/or initial cargo container metadata (contract acceptance, market purchase).
2) Centralize and normalize container_meta initialization so all freight:
   - Has a container_id
   - Has provenance information
   - Has a packed_tick derived from the current game time
3) Preserve existing behavior by assigning defaults only at creation time, without altering later edit flows or validation logic.

---

## Verification

### Manual Test Steps
1. Accept a contract and inspect the resulting FreightDoc in Captain’s Quarters:
   - Container metadata exists
   - Container is sealed
   - Provenance and packed_tick are present
2. Purchase freight from a market and inspect the resulting FreightDoc:
   - Container metadata exists
   - Container is unsealed
   - Provenance and packed_tick are present

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched
- [ ] Contract completion and market trading still function as before

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0026-refactor-container-provenance-normalization/`
2) Write this job verbatim to `codex/runs/issue-0026-refactor-container-provenance-normalization/job.md`
3) Create `codex/runs/issue-0026-refactor-container-provenance-normalization/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0026-refactor-container-provenance-normalization`

Codex must write final results only to:
- `codex/runs/issue-0026-refactor-container-provenance-normalization/results.md`

Results must include:
- Summary of refactor
- Files changed
- Manual test results
- Confirmation behavior is unchanged
- Follow-ups / known gaps (if any)

---

## Migration Notes
None.

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate
