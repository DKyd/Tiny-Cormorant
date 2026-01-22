# Feature Job

## Metadata (Required)
- Issue/Task ID: 0064
- Short Title: Customs Pressure UI Surfacing
- Run Folder Name: issue-0064-customs-pressure-ui
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-22

---

## Goal
Surface customs pressure as a readable, player-facing indicator in the Port UI.  
This feature improves player perception of risk and enforcement climate without introducing inspections, enforcement, or simulation.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Customs pressure remains a read-only, deterministic value.
- No enforcement, inspections, fines, or gameplay consequences are introduced.
- Customs pressure does not affect time, economy, or contracts.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not introduce customs inspections, random checks, or penalties.
- Do not persist customs pressure or add any saved state.
- Do not modify how customs pressure is calculated.

---

## Context
The system already provides a deterministic, read-only helper:
`GameState.get_customs_pressure_bucket(context := {}) -> String`, which derives a pressure bucket
(Low / Elevated / High / Unknown) based on system security and freight document evidence.

Currently, this information is not visible to the player. The Port UI already surfaces other
perception-oriented context (organization presence, black market access), making it the correct
place to surface customs pressure as environmental information.

This job adds visibility only and does not alter gameplay behavior.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only.

- Query customs pressure using the existing GameState helper when the Port view is active.
- Display the pressure bucket in the Port header alongside other contextual indicators.
- Use plain, readable text (e.g., “Customs: Low / Elevated / High / Unknown”).
- Ensure the display updates when docking at a new location.
- Do not emit logs or side effects from UI rendering.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/Port.gd`
- `scripts/ui/PortHeader.gd`
- `scenes/ui/PortHeader.tscn`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
- What inputs must remain stable?
- What must not introduce randomness or time-based variance?

- Customs pressure buckets must remain deterministic for a given location and cargo state.
- UI rendering must not introduce randomness or time-based variance.
- The feature must not alter GameState.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The Port header displays a customs pressure label when docked.
- [ ] The label reflects the value returned by `GameState.get_customs_pressure_bucket()`.
- [ ] No gameplay behavior or logs are triggered by viewing the customs pressure.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and dock at a location with different security levels.
2. Observe the Port header and confirm the customs pressure label is visible.
3. Change cargo or move to another system and confirm the label updates appropriately.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- No current location available.
- Customs pressure helper returns “Unknown”.
- Port header loads before freight documents are initialized.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Pressure label could be misread as enforcement; wording must remain informational.
- Risk: Overloading the header; keep layout minimal and readable.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0064-customs-pressure-ui/`
2) Write this job verbatim to `codex/runs/issue-0064-customs-pressure-ui/job.md`
3) Create `codex/runs/issue-0064-customs-pressure-ui/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0064-customs-pressure-ui`

Codex must write final results only to:
- `codex/runs/issue-0064-customs-pressure-ui/results.md`

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
