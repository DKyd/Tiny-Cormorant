# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0022
- Short Title: Captain’s Quarters as Navigable Space
- Run Folder Name: issue-0022-feature-captains-quarters-as-space
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Goal
Make Captain’s Quarters a first-class navigable space that behaves like Bridge and Port.  
Entering Captain’s Quarters replaces the active view rather than displaying an overlay, and exiting is handled exclusively via the global navigation bar.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via GameState.
- Captain’s Quarters functionality (FreightDoc editing/destruction) remains gated logically, not visually.
- Navigation semantics are consistent across Bridge, Port, and Captain’s Quarters.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add new FreightDoc capabilities or rules.
- Do not change smuggling, inspection, or legality mechanics.
- Do not modify visual theme, layout polish, or UI styling.

---

## Context
Captain’s Quarters currently exists as a semi-opaque overlay panel instantiated from MainGame.gd.  
Bridge and Port are navigable views that replace the active scene via `_show_view()`.  
This inconsistency creates confusing navigation semantics and duplicates close/teardown logic.  
A Captain’s Quarters UI panel already exists and should be reused inside a full view.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Introduce a Captain’s Quarters view scene that behaves like Bridge and Port.
- Embed or instantiate the existing Captain’s Quarters panel inside the new view.
- Remove any internal Close button or overlay-specific teardown logic.
- Update the Quarters navigation button to use `_show_view()` instead of toggling an overlay.
- Rely exclusively on the global navigation bar for entering and exiting Captain’s Quarters.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- scripts/MainGame.gd
- scripts/ui/CaptainsQuartersPanel.gd
- scenes/ui/CaptainsQuartersPanel.tscn
- scenes/CaptainsQuarters.tscn

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes
- [ ] No

If Yes, list exact new file paths:

- scenes/CaptainsQuarters.tscn

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
  - None
- Save/load verification requirements:
  - None

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Pressing the Captain’s Quarters button replaces the active view (no overlay).
- [ ] Captain’s Quarters has no internal Close button or self-teardown behavior.
- [ ] Player can freely navigate between Bridge, Port, and Captain’s Quarters using the global navigation bar.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and navigate to Bridge or Port.
2. Click the Captain’s Quarters button and confirm the active view is replaced.
3. Navigate back to Bridge or Port using the global navigation bar.
4. Confirm FreightDoc editing works identically to Issue-0020 behavior.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Captain’s Quarters view fails to load ? log error and remain in current view.
- Repeated navigation clicks do not stack views or orphan nodes.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Requires removing overlay-specific assumptions from Captain’s Quarters UI.
- Future UI polish should be handled in a separate job to avoid scope creep.

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
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
