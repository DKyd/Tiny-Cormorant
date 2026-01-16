# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0024
- Short Title: FreightDoc Authenticity & Evidence Flags
- Run Folder Name: issue-0024-feature-freightdoc-authenticity-evidence-flags 
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Introduce runtime-only authenticity and evidence indicators for FreightDocs so that document edits generate traceable evidence without causing immediate penalties or inspections. These indicators must be visible to systems and UI but have no enforcement effects yet.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- FreightDoc edits continue to emit immutable edit events and do not directly cause failure states.
- No inspections, fines, seizures, reputation changes, or legality checks are introduced.
- All FreightDoc authenticity and evidence data is derived at runtime and does not alter persistence format.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not implement customs inspections, port authority inspections, or any enforcement logic.
- Do not add save/load persistence or migration for authenticity or evidence fields.

---

## Context
FreightDocs already support modification and destruction via Captain’s Quarters, emitting immutable edit events with event_type, source, tick, and before/after data. The Captain’s Quarters now includes a live inspector panel that reflects FreightDoc state in real time. What is missing is any mechanical meaning derived from these edits beyond raw event history.

The project has explicitly chosen an evidence-based design (Option C), where edits generate evidence and reduce authenticity rather than triggering binary pass/fail checks.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Derive evidence flags and authenticity score at runtime from FreightDoc edit events.
- Introduce a small, explicit set of evidence flags (e.g. quantity modified, container metadata modified, document destroyed).
- Compute an authenticity_score starting at 100 and reduced deterministically by evidence flags.
- Expose derived authenticity and evidence via GameState helpers without changing saved FreightDoc structure.
- Ensure all derived data updates automatically when FreightDocs change.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/ui/CaptainsQuartersPanel.gd`

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

- `GameState.get_doc_authenticity(doc_id: String)`
- `GameState.get_doc_evidence_flags(doc_id: String)`

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None (runtime-only derived data)
- Migration / backward-compat expectations:
  - Not applicable
- Save/load verification requirements:
  - Existing saves load unchanged; authenticity and evidence derive cleanly at runtime

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Editing declared quantity adds an evidence flag and reduces authenticity_score.
- [ ] Editing container metadata adds an evidence flag and reduces authenticity_score.
- [ ] Destroying a FreightDoc adds an evidence flag and sets authenticity_score to 0.
- [ ] Authenticity and evidence update live in the Captain’s Quarters inspector without manual refresh.
- [ ] No inspections, penalties, or gameplay consequences occur as a result of these changes.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Open Captain’s Quarters and select an active FreightDoc.
2. Modify declared quantity and observe evidence/authenticity update in the inspector.
3. Modify container metadata and confirm additional evidence flags appear.
4. Destroy a FreightDoc and verify evidence reflects destruction and authenticity_score is 0.
5. Confirm no inspections, fines, or errors occur.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- FreightDocs with no edit events show full authenticity and no evidence flags.
- Unknown or future edit event types do not crash authenticity derivation.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Authenticity tuning values are provisional and may need adjustment once inspections are implemented.
- Future persistence of authenticity will require a dedicated migration job.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0024-freightdoc-authenticity-evidence-flags/`
2) Write this job verbatim to `codex/runs/issue-0024-freightdoc-authenticity-evidence-flags/job.md`
3) Create `codex/runs/issue-0024-freightdoc-authenticity-evidence-flags/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0024-freightdoc-authenticity-evidence-flags`

Codex must write final results only to:
- `codex/runs/issue-0024-freightdoc-authenticity-evidence-flags/results.md`

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
