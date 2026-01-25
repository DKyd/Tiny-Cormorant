# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0077
- Short Title: Add player-facing Customs inspection logs for entry/sale/departure attempts
- Run Folder Name: issue-0077-customs-inspection-logging
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Ensure Customs inspection attempts at the three Level 1 trigger points (system entry, legal sale, and port departure) generate clear, human-readable log entries that explain when an inspection was attempted and (at minimum) what action it was for, without introducing new enforcement or mutating gameplay state.

---

## Invariants (Must Hold After This Job)
- Inspections remain deterministic and continue to use `GameState.roll_customs_inspection(...)` (no global RNG).
- Inspections do not mutate cargo, credits, or freight docs and do not block travel or sale.
- Triggers remain player-action-boundary only and continue to fire at most once per qualifying player action.

---

## Non-Goals
- No changes to inspection chance tuning, pressure bucket derivation, jurisdiction selection, or evidence logic.
- No new penalties, holds, fines, delays, cargo denial, or travel/sale blocking.

---

## Context
We now have Level 1 Customs inspection gating wired for:
- system entry (`Customs.run_entry_check`)
- legal cargo sale (`Customs.run_sale_check`)
- port departure (`Customs.run_departure_check`)

However, player-facing feedback is inconsistent: entry checks currently emit a clear `Log.add_entry(...)` line on inspection, while sale/departure checks may run without a comparable player-facing log. This makes the system feel “silent” and undermines the North Star requirement that outcomes be explainable and that risk is legible to the player.

This job is purely about consistent, readable logging around inspection attempts/results for the three Level 1 triggers.

---

## Proposed Approach
- Add consistent log entries in Customs helpers for each action (`ENTRY_CLEARANCE`, `SELL_CARGO_LEGAL`, `PORT_DEPARTURE_CLEARANCE`) when an inspection attempt occurs.
- Ensure log entries identify:
  - action type in plain language (Entry / Departure / Sale)
  - the relevant system/location name where available
  - the inspection classification (if produced) or a safe fallback
- Do not log anything when no inspection occurs (avoid spam).
- Keep changes minimal and localized to logging only.

---

## Files: Allowed to Modify (Whitelist)
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
- Logging must not introduce new randomness sources or depend on non-deterministic time.
- Inspection rolls and jurisdiction selection remain unchanged; logging must be a pure side-effect after an inspection attempt occurs.

---

## Acceptance Criteria (Must Be Testable)
- [ ] When an entry inspection attempt occurs, the player log includes a clear message indicating Customs inspected entry paperwork and includes the reported classification (or a safe fallback).
- [ ] When a legal sale inspection attempt occurs, the player log includes a clear message indicating Customs inspected sale paperwork and includes the reported classification (or a safe fallback).
- [ ] When a port departure inspection attempt occurs, the player log includes a clear message indicating Customs inspected departure paperwork and includes the reported classification (or a safe fallback).

---

## Manual Test Plan
1. Load a save, travel between systems repeatedly until an entry inspection occurs; confirm a readable log line appears for entry inspections and includes a classification.
2. At a port with legal market access, sell legal cargo repeatedly until a sale inspection occurs; confirm a readable log line appears for sale inspections and includes a classification.
3. While docked, attempt inter-system travel repeatedly until a departure inspection occurs; confirm a readable log line appears for departure inspections and includes a classification.

---

## Edge Cases / Failure Modes
- If system/location dictionaries are missing or empty, logs must safely fall back to IDs without errors.
- If `run_customs_inspection` returns a report missing `classification`, logs must print a safe fallback (e.g., `unknown`) rather than crashing or printing raw dictionaries.

---

## Risks / Notes
- Keep logging volume sane: no logs should be emitted when no inspection occurs.
- Avoid duplicate logs (do not log both in Customs and again elsewhere for the same inspection attempt).
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

---

## Logging Checklist
- [x] All explicit player actions that succeed or fail emit a clear log entry
- [x] All time advancement paths log a reason and tick delta
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
