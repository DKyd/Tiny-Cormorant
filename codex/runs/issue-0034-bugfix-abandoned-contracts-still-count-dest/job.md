# Bugfix Job

## Metadata (Required)
- Issue/Task ID: Issue-0034
- Short Title: Abandoned contracts still counted in Galaxy Map destination badges
- Run Folder Name: issue-0034-bugfix-abandoned-contracts-still-count-dest
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Bug Description
After abandoning a contract (by destroying its contract FreightDoc), the Galaxy Map still shows destination indicators such as `[Dest: 1]` for the destination location/system. This persists even though the contract can no longer be completed.

---

## Expected Behavior
Once a contract is abandoned, it should no longer be counted toward Galaxy Map destination badges. Destination indicators should reflect only non-abandoned active contracts.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Accept a contract with a destination in another system/location (confirm the Galaxy Map shows a `[Dest: 1]`-style indicator for that destination).
2. Go to Captain’s Quarters and destroy the contract FreightDoc (abandoning the contract).
3. Return to the Galaxy Map and observe destination indicators.

---

## Observed Output / Error Text
- No crash.
- Galaxy Map still shows `[Dest: 1]` for the abandoned contract destination.

---

## Suspected Area (Optional)
- `scripts/MapPanel.gd`
  - `_count_active_destinations_to_location()` (and any system-level equivalent)
- `singletons/GameState.gd`
  - abandonment tracking state + public query method for abandonment

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MapPanel.gd`
- `singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] After abandoning a contract (paperwork destroyed), the Galaxy Map no longer counts that contract toward `[Dest: N]` destination indicators.
- [ ] Non-abandoned active contracts still count toward destination indicators correctly.
- [ ] No save/load behavior changes are introduced (abandonment remains runtime-only as currently implemented).

---

## Regression Checks
List behaviors that must still work after the fix.

- Galaxy Map still renders system/location lists normally (no missing entries, no crashes).
- Contract completion still works for non-abandoned contracts at the correct destination.
- Abandoned contract completion remains blocked (no reward payout, no cargo clearing).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Start the game, accept a contract to a different destination, and confirm the Galaxy Map shows `[Dest: 1]` for that destination.
2. In Captain’s Quarters, destroy the contract FreightDoc (triggering abandonment).
3. Return to the Galaxy Map and confirm the destination indicator no longer counts the abandoned contract (e.g., `[Dest: 0]` / indicator removed).
4. Accept a new contract and confirm destination indicators work normally for the new active (non-abandoned) contract.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0034-bugfix-abandoned-contracts-still-count-dest/`
2) Write this job verbatim to `codex/runs/issue-0034-bugfix-abandoned-contracts-still-count-dest/job.md`
3) Create `codex/runs/issue-0034-bugfix-abandoned-contracts-still-count-dest/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0034-bugfix-abandoned-contracts-still-count-dest`

Codex must write final results only to:
- `codex/runs/issue-0034-bugfix-abandoned-contracts-still-count-dest/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
