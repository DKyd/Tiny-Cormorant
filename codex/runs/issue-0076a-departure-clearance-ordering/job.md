# Feature Job — Follow-up (Issue 0076a)

## Metadata (Required)
- Issue/Task ID: issue-0076a
- Short Title: Fix departure clearance trigger ordering + register action requirements
- Run Folder Name: issue-0076a-departure-clearance-ordering
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Ensure port departure clearance checks only occur on a successful departure attempt (i.e., after affordability is confirmed), and ensure the departure action is recognized by surface compliance requirements so it does not appear as an unsupported action.

---

## Invariants (Must Hold After This Job)
- Deterministic inspection rolls remain deterministic and seed-based (no global RNG).
- Inspections never mutate cargo, credits, freight docs, or block travel/sale outcomes.
- Inspection triggers occur only at player-action boundaries and only when the underlying action succeeds.

---

## Non-Goals
- Do not introduce fines, holds, seizures, delays, or travel blocking.
- Do not change inspection chance tuning, pressure bucket thresholds, or evidence/authenticity logic.

---

## Context
Currently, `Customs.run_departure_check(system_id, location_id)` exists and is invoked from `GameState.travel_to_system`.
However, the call occurs before the travel affordability check, meaning a failed travel attempt (insufficient funds) can still trigger a “departure clearance” inspection attempt.
Additionally, `GameState.run_customs_inspection` is passed an `action` string. If `PORT_DEPARTURE_CLEARANCE` is not present in `SURFACE_ACTION_REQUIREMENTS`, the action is treated as unsupported and may yield unintended surface-compliance failure behavior.

---

## Proposed Approach
- Move the `Customs.run_departure_check(...)` call in `GameState.travel_to_system` so it only runs after destination validation and the “not enough credits” early return.
- Keep the departure check before travel state mutation (credit deduction, clearing `current_location_id`) so it uses the departure tick and preserves departure location identity.
- Add a `PORT_DEPARTURE_CLEARANCE` entry to `SURFACE_ACTION_REQUIREMENTS` matching existing Level 1 patterns (same as `ENTRY_CLEARANCE`).
- Keep changes minimal and strictly within the whitelist.

---

## Files: Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

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
- Modify call site ordering of existing `Customs.run_departure_check(...)` usage.
- Extend `SURFACE_ACTION_REQUIREMENTS` to include `PORT_DEPARTURE_CLEARANCE`.

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
- Deterministic elements:
  - The departure clearance roll must remain deterministic via `GameState.roll_customs_inspection(...)`.
- Stable inputs:
  - Inputs to the roll must remain `(system_id, location_id, action, time_tick)`.
- Must not introduce:
  - Global RNG usage or time-based nondeterminism.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Attempting inter-system travel with insufficient funds does **not** trigger a departure clearance inspection attempt (no departure-inspection log emitted).
- [ ] Successful inter-system travel from a docked state triggers at most one deterministic departure clearance inspection attempt (pressure-gated), before credits/system/location mutations.
- [ ] `PORT_DEPARTURE_CLEARANCE` is recognized by surface compliance (no “unsupported_action” issue generated solely due to missing action registration).

---

## Manual Test Plan
1. Start docked at a location with any customs pressure bucket.
2. Set player credits below the required travel cost, attempt travel to another system:
   - Verify travel fails and no departure clearance inspection log/inspection signal occurs.
3. Set credits high enough, attempt travel again while docked:
   - Verify departure clearance inspection attempt occurs only sometimes (pressure + deterministic roll), and occurs before location clears.
4. Optionally inspect `GameState.run_customs_inspection` report for departure action:
   - Verify no `action_unsupported` flag is set for `PORT_DEPARTURE_CLEARANCE`.

---

## Edge Cases / Failure Modes
- If `current_location_id == ""` (not docked), departure clearance must not run.
- If destination system is invalid, departure clearance must not run.

---

## Risks / Notes
- Moving the call may affect which tick seeds the departure roll; this is intended (departure tick, not arrival tick).
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0076a-departure-clearance-ordering/`
2) Write this job verbatim to `codex/runs/issue-0076a-departure-clearance-ordering/job.md`
3) Create `codex/runs/issue-0076a-departure-clearance-ordering/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0076a-departure-clearance-ordering`

Codex must write final results only to:
- `codex/runs/issue-0076a-departure-clearance-ordering/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
