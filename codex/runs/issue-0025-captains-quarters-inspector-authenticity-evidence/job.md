# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0025
- Short Title: Captain’s Quarters Inspector Shows Authenticity & Evidence
- Run Folder Name: issue-0025-captains-quarters-inspector-authenticity-evidence
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Extend the Captain’s Quarters Selected FreightDoc inspector to display the document’s derived authenticity_score and evidence_flags. These values must update live when the selected FreightDoc changes.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations still occur via GameState.
- No inspections, penalties, seizures, reputation changes, or legality checks are introduced.
- No persistence changes or migrations are added for authenticity/evidence (runtime-only derived).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add or change authenticity/evidence derivation logic (that belongs to Issue-0024).
- Do not add new gameplay consequences, checks, or additional logging.

---

## Context
Issue-0023 added a read-only Selected FreightDoc inspector section in Captain’s Quarters and a signal-driven refresh flow via GameState.freight_doc_changed. Issue-0024 introduced runtime-only evidence flag derivation and authenticity scoring via:
- GameState.get_doc_evidence_flags(doc_id)
- GameState.get_doc_authenticity(doc_id)

What is missing is UI visibility: the inspector does not yet display authenticity_score or evidence flags, even though they are now derivable.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Add two read-only inspector rows: Authenticity and Evidence.
- Populate Authenticity using GameState.get_doc_authenticity(_selected_doc_id).
- Populate Evidence using GameState.get_doc_evidence_flags(_selected_doc_id) with simple formatting.
- Ensure inspector values clear on empty/missing selection (inspector-only fields).
- Ensure values update live via existing freight_doc_changed refresh/render flow.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`

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
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not applicable
- Save/load verification requirements:
  - Not applicable

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The Selected FreightDoc inspector displays authenticity_score as an integer 0–100 for the selected FreightDoc.
- [ ] The Selected FreightDoc inspector displays evidence_flags for the selected FreightDoc (shows “None” when empty).
- [ ] Authenticity and evidence display update live when the selected FreightDoc is edited or destroyed, without requiring manual refresh actions and without wiping user edit inputs.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Open Captain’s Quarters and select an active FreightDoc; confirm Authenticity shows 100 and Evidence shows “None” (for an unedited doc).
2. Modify declared quantity; confirm Evidence includes declared_quantity_modified and Authenticity decreases accordingly.
3. Modify container metadata; confirm Evidence includes container_meta_modified and Authenticity decreases accordingly.
4. Destroy the FreightDoc; confirm Evidence includes document_destroyed and Authenticity is 0.
5. Confirm that during live updates, the editable input fields (SpinBox/LineEdits) are not cleared unless the player changes them.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Selecting a FreightDoc with missing/empty edit_events does not crash and shows Evidence “None”.
- If the selected FreightDoc is missing after a list rebuild, the inspector clears inspector-only fields and buttons update correctly.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Node path mismatches between .gd @onready bindings and .tscn nodes will cause runtime errors; keep names/paths consistent.
- Evidence flag display format is provisional; future UI may want a more detailed evidence history view.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0025-captains-quarters-inspector-authenticity-evidence/`
2) Write this job verbatim to `codex/runs/issue-0025-captains-quarters-inspector-authenticity-evidence/job.md`
3) Create `codex/runs/issue-0025-captains-quarters-inspector-authenticity-evidence/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0025-captains-quarters-inspector-authenticity-evidence`

Codex must write final results only to:
- `codex/runs/issue-0025-captains-quarters-inspector-authenticity-evidence/results.md`

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
