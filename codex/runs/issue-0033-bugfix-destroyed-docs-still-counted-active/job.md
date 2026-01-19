# Bugfix Job

## Metadata
- Issue/Task ID: Issue-0033
- Short Title: Destroyed FreightDocs still counted as active destination docs on Galaxy Map
- Run Folder Name: issue-0033-bugfix-destroyed-docs-still-counted-active
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Bug Description
After destroying (shredding) a contract FreightDoc to abandon a mission, the Galaxy Map still indicates that the contract destination system has an “active document destination” (e.g., a docs marker / `[Docs]`-style indicator). The UI continues to treat the destroyed FreightDoc as active for destination counting.

---

## Expected Behavior
Destroyed FreightDocs should not be treated as active paperwork for destination indicators. Once a FreightDoc is destroyed, the Galaxy Map should no longer show that destination as having active freight paperwork associated with it.

---

## Repro Steps
1. Accept a contract whose destination is a different system (so the Galaxy Map shows a docs destination marker/indicator for that system).
2. Go to Captain’s Quarters and destroy the associated contract FreightDoc (paperwork destruction / abandonment).
3. Open the Galaxy Map and observe the destination system indicator.

---

## Observed Output / Error Text
- No crash.
- The Galaxy Map continues to show an active document destination marker/indicator for the contract’s destination system after the FreightDoc was destroyed.

---

## Suspected Area (Optional)
- `singletons/GameState.gd`
  - `destroy_freight_doc()` sets `is_destroyed = true` but may not update `status`.
  - Destination doc counting likely filters by `status == "active"` (e.g., `get_docs_for_destination()`).

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- Any files under `codex/` except `codex/runs/<active-job>/job.md` and `codex/runs/<active-job>/results.md`

---

## New Files
- Not allowed (except `results.md` in the active run folder if missing).

---

## Proposed Fix (Bugfix-appropriate)
In the successful destruction path of `GameState.destroy_freight_doc()`, set the FreightDoc’s `status` to `"destroyed"` (or otherwise ensure it is no longer `"active"`), so destination doc queries that filter by active status stop counting destroyed docs.

---

## Acceptance Criteria (Must Be Testable)
- [ ] After destroying a contract FreightDoc, the Galaxy Map no longer shows the destination system as having an active FreightDoc destination indicator.
- [ ] Destroying a FreightDoc still records destruction evidence and does not change cargo, money, or contract cargo state.
- [ ] No changes are made outside `singletons/GameState.gd`.

---

## Manual Test Plan
1. Start a run, accept a contract to another system, and confirm the Galaxy Map shows the destination docs indicator.
2. Destroy the contract FreightDoc in Captain’s Quarters.
3. Return to the Galaxy Map and confirm the docs indicator for that destination system is removed (or no longer shown).
4. Confirm no crashes and that cargo quantities remain unchanged.

---

## Edge Cases / Failure Modes
- Destroying a FreightDoc that is already destroyed should not change status again or introduce inconsistent values.
- Older FreightDocs that may not have a `status` field should continue to normalize safely (no crashes).

---

## Risks / Notes
- This change assumes the Galaxy Map’s doc destination indicator relies on `status == "active"` rather than `is_destroyed`. If the map uses `is_destroyed`, the fix may need to adjust the map query logic—but that would require touching additional files and must trigger a STOP.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0033-bugfix-destroyed-docs-still-counted-active/`
2) Write this job verbatim to `codex/runs/issue-0033-bugfix-destroyed-docs-still-counted-active/job.md`
3) Create `codex/runs/issue-0033-bugfix-destroyed-docs-still-counted-active/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0033-bugfix-destroyed-docs-still-counted-active`

Codex must write final results only to:
- `codex/runs/issue-0033-bugfix-destroyed-docs-still-counted-active/results.md`

Results must include:
- Root cause (1–3 sentences)
- Fix summary
- Files changed + purpose
- Manual test steps executed
- Regression checks
- Assumptions made
- Follow-ups (if any)
