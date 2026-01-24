# Feature Job

## Metadata (Required)
- Issue/Task ID: ISSUE-0072
- Short Title: ENTRY_CLEARANCE checks use pressure bucket (not security level) + action context
- Run Folder Name: issue-0072-entry-clearance-pressure-trigger
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
ENTRY_CLEARANCE customs checks (system entry clearance) must be gated by **Customs Pressure**, not by a legacy security-level chance table.  
When an entry check occurs, it must call `GameState.run_customs_inspection` with `action: "ENTRY_CLEARANCE"` so Level-1 surface/action compliance can explain failures.

---

## Invariants (Must Hold After This Job)
- Customs checks happen only at **player-action boundaries** (entry clearance is a player-triggered boundary).
- Entry clearance check frequency is governed by **pressure** (derived from existing deterministic world facts), not raw system security level.
- Customs does not run checks for black market interactions.
- No freight docs are mutated by inspection logic (inspection is read-only).

---

## Non-Goals
- Do not implement enforcement (fines/seizures/holds) or any blocking behavior.
- Do not add Level 2+ inspection depth logic or cross-document reconciliation.
- Do not refactor ownership of customs logic out of `GameState` (architecture alignment is a separate job).
- Do not change market sell behavior (SELL_CARGO_LEGAL already triggers inspection; do not touch it).

---

## Context
Pressure currently “lives” in `GameState.gd` via:
- `get_customs_pressure(location_id) -> float` (deterministic blend of security + government influence - cartel influence)
- `CUSTOMS_PRESSURE_LOW_MAX` and `CUSTOMS_PRESSURE_ELEVATED_MAX` thresholds exist

However, `get_customs_pressure_bucket(location_id)` is currently implemented using only system security level (Low/Elevated/High) and does NOT bucketize `get_customs_pressure()`.

Separately, there is a legacy customs entry-check singleton that:
- uses a security-level chance table + `randf()`
- calls `GameState.run_customs_inspection({system_id, location_id: ""})` with no action context

We need entry checks to be based on GameState pressure (North Star) and to pass `action: "ENTRY_CLEARANCE"`.

---

## Proposed Approach
- Update `GameState.get_customs_pressure_bucket(location_id)` to compute a bucket from `get_customs_pressure(location_id)` using:
  - `CUSTOMS_PRESSURE_LOW_MAX`
  - `CUSTOMS_PRESSURE_ELEVATED_MAX`
  - return values must remain exactly: `"Low"`, `"Elevated"`, `"High"`
- Update the legacy entry-check singleton to:
  - compute `bucket := GameState.get_customs_pressure_bucket(location_id)` (or best-effort if location_id is blank)
  - map bucket to a chance (local table in the singleton is acceptable; do not reintroduce security-level chance)
  - roll once to decide whether to run the inspection
  - if it runs, call:
    - `GameState.run_customs_inspection({ "system_id": system_id, "location_id": location_id, "action": "ENTRY_CLEARANCE" })`
- Ensure entry checks do not “invalidate” when there is no cargo:
  - `SURFACE_ACTION_REQUIREMENTS.ENTRY_CLEARANCE.requires_cargo_present` already makes action validation no-op when hold is empty.
  - The entry trigger may still call inspection, but it should not manufacture new failure modes.
- Logging:
  - Keep log volume reasonable (no spam loops).
  - The existing GameState inspection log entry is sufficient; do not add per-frame logs.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd` (or the actual legacy customs singleton file currently performing entry checks)

NOTE: If the legacy singleton is not at `res://singletons/Customs.gd`, Codex must STOP and report the correct file path before editing it.

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
- N/A

---

## Public API Changes
- None required.
- If necessary for correctness, the entry-check singleton may add an optional `location_id` parameter to its entry-check function, but only if it can be done without changing other call sites. Otherwise, it must use best-effort defaults.

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
- `get_customs_pressure()` and the resulting bucket must remain deterministic for a given world state.
- The decision to run an entry check may remain probabilistic for now (existing behavior), but must be driven by the pressure bucket.
- Do not introduce time-based variance beyond the one roll per entry boundary.

---

## Acceptance Criteria (Must Be Testable)
- [ ] `GameState.get_customs_pressure_bucket()` buckets `get_customs_pressure()` using `CUSTOMS_PRESSURE_LOW_MAX` and `CUSTOMS_PRESSURE_ELEVATED_MAX`, returning `"Low"`, `"Elevated"`, or `"High"`.
- [ ] The legacy entry-check no longer uses security-level chance tables as its primary gating mechanism; it uses the pressure bucket.
- [ ] When an entry check occurs, `GameState.run_customs_inspection` receives `action: "ENTRY_CLEARANCE"`.
- [ ] No new inspections are triggered for black market flows.

---

## Manual Test Plan
1. Dock at two different locations with visibly different pressure (use the Port header customs pressure line as the cue).
2. With cargo present, travel away and re-enter/arrive in each location’s system entry scenario repeatedly (enough times to feel frequency differences).
3. Confirm checks appear more often in higher pressure locations than low pressure locations (qualitative check).
4. Inspect the customs log entry context (debug print or temporary breakpoint is acceptable during testing) to confirm the report includes `doc_summary.action == "ENTRY_CLEARANCE"` when triggered.
5. Repeat with an empty cargo hold and confirm no action-required-doc invalidation occurs.

---

## Edge Cases / Failure Modes
- If `location_id` is empty at system entry, pressure defaults safely (bucket `"Low"` is acceptable).
- If `Galaxy.get_location(location_id)` is empty, pressure should safely default to `"Low"` without errors.
- If `get_customs_pressure_bucket` is used elsewhere, its output strings must remain stable.

---

## Risks / Notes
- Risk: call-site ambiguity (multiple entry hooks). Codex must update only the single legacy entry-check path and report if multiple exist.
- Risk: pressure bucket behavior changes could affect UI expectations. This is intentional: it aligns UI pressure surfacing with actual check frequency.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0072-entry-clearance-pressure-trigger/`
2) Write this job verbatim to `codex/runs/issue-0072-entry-clearance-pressure-trigger/job.md`
3) Create `codex/runs/issue-0072-entry-clearance-pressure-trigger/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0072-entry-clearance-pressure-trigger`

Codex must write final results only to:
- `codex/runs/issue-0072-entry-clearance-pressure-trigger/results.md`

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
