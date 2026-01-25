# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0076b
- Short Title: Move departure clearance trigger to successful travel path
- Run Folder Name: issue-0076b-departure-clearance-order
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Ensure `PORT_DEPARTURE_CLEARANCE` inspections only attempt when an inter-system travel action is actually going to succeed, so failed travel (e.g., insufficient credits) cannot trigger a departure inspection attempt.

---

## Invariants (Must Hold After This Job)
- Inspections remain deterministic and use `GameState.roll_customs_inspection(...)` (no global RNG).
- Inspections do not mutate cargo, credits, or freight docs and do not block travel.
- Triggers remain player-action-boundary only.

---

## Non-Goals
- No changes to inspection chance tuning, pressure buckets, or evidence logic.
- No new penalties, holds, fines, delays, or travel blocking.

---

## Context
`Customs.run_departure_check(current_system_id, current_location_id)` is currently invoked during `GameState.travel_to_system(...)`, but it is placed such that it can run even when the travel attempt later fails early (most importantly: insufficient credits). This creates an unfair “departure clearance” attempt when the player never actually departs.

---

## Proposed Approach
- In `GameState.travel_to_system(...)`, move the `Customs.run_departure_check(...)` call so it occurs:
  - after destination validity checks, and after the “insufficient credits” early return path
  - while `current_location_id` still represents the departure location (i.e., before it is cleared/changed)
  - before any state mutation relevant to travel (credit deduction, tick advance, system/location updates)
- Keep the change minimal and localized (no refactors).

---

## Files: Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Public API Changes
None.

---

## Data Model & Persistence
- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- The departure clearance roll must remain deterministic and must only depend on stable inputs already used by `roll_customs_inspection`.
- Do not introduce new randomness sources or time-based variance.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Attempt inter-system travel with insufficient funds: no departure clearance inspection attempt occurs.
- [ ] Attempt inter-system travel with sufficient funds while docked: departure clearance may attempt (pressure + deterministic roll) exactly once per successful travel action.
- [ ] If `current_location_id == ""` (not docked), departure clearance is not attempted.

---

## Manual Test Plan
1. Dock at a port with any customs pressure bucket.
2. Reduce credits below travel cost; attempt travel:
   - verify travel fails and no departure clearance inspection/log occurs.
3. Increase credits above travel cost; attempt travel again:
   - verify departure clearance inspection may occur (pressure + deterministic roll), and travel proceeds normally.
4. Undock (so `current_location_id == ""`), attempt travel:
   - verify no departure clearance attempt.

---

## Edge Cases / Failure Modes
- Invalid destination system: no departure clearance attempt.
- Not docked (`current_location_id == ""`): no departure clearance attempt.

---

## Risks / Notes
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory) ?? NEW
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs
