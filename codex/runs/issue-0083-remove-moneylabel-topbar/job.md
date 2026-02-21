# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0083
- Short Title: Remove redundant MoneyLabel node from MainGame TopBar
- Run Folder Name: issue-0083-remove-moneylabel-topbar
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Remove the broken and redundant credits counter node at `VBoxContainer/TopBar/MoneyLabel` from the MainGame UI and delete any dead/duplicate wiring that only exists to support it. This is a structural cleanup to reduce UI complexity and eliminate a stale/broken display path.

No behavior change: credits are still tracked in GameState as before; this only removes an unused/redundant UI element and its supporting glue code.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.
- No new credits UI replacement is introduced.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Removing `MoneyLabel` does not break scene loading or dock UI flow.

---

## Scope

### Files Allowed to Modify (Whitelist)
- `scripts/MainGame.gd`
- `scripts/ui/**`            # only if there is a direct dependency on MoneyLabel wiring
- `singletons/GameState.gd`  # only if there is dead signal/plumbing solely for MoneyLabel

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Locate all references to the node path `VBoxContainer/TopBar/MoneyLabel` (including `get_node()`, `$`, cached vars, and signal hookups).
2) Remove the MoneyLabel-related code paths:
   - cached node references
   - update functions that only exist to refresh the label
   - signal connections that only exist to refresh the label
   - any redundant UI-state mirrors that duplicate GameState credits
3) Ensure remaining UI and state flow is unchanged:
   - scene still loads without missing-node errors
   - any shared “top bar refresh” function still works (remove only the money line)
   - no new dependencies introduced

---

## Verification

### Manual Test Steps
1. Launch game to MainGame; confirm no “Node not found” / invalid get_node errors in output.
2. Dock at a port; open/close market and black market UIs; confirm TopBar still renders and no UI regressions.
3. Perform a buy and a sell action; confirm credits still change in the underlying state (via any existing non-TopBar readout/logs) and no errors occur.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

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
