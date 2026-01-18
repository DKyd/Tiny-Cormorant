# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0032
- Short Title: Persistent Right-Side Log Panel
- Run Folder Name: issue-0032-feature-persistent-log-panel
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-17

---

## Goal
Move the game log from its current bottom-of-screen placement to a persistent right-side panel that remains visible across all primary views (Bridge, Port, Captain’s Quarters).  
The log should provide continuous player feedback without obstructing core UI interactions.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The log remains read-only with respect to game state.
- All log entries continue to be emitted exclusively via `Log.add_entry()`.
- Scene navigation and view swapping behavior remains unchanged.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- This job must not change log content, formatting rules, or log retention limits.
- This job must not introduce new log-producing behavior or alter logging semantics.

---

## Context
The game currently renders the log at the bottom of the MainGame view, causing it to disappear or shift during view changes.  
The `Log` singleton already manages log storage and emission consistently.  
There is no persistent UI container that survives view swaps for log display, and the current placement competes for vertical screen space.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).

- Introduce a persistent right-side log panel anchored outside view-specific content.
- Ensure the log panel is instantiated once and survives view changes.
- Rewire existing log UI to render within the new panel without changing data flow.
- Adjust layout so primary views resize or account for the log panel width.
- Preserve existing log scrolling and capped-history behavior.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- scenes/MainGame.tscn
- scripts/MainGame.gd
- scenes/ui/LogPanel.tscn
- scripts/ui/LogPanel.gd

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`

---

## New Files Allowed?
- [ ] Yes
- [x] No

If Yes, list exact new file paths:

- N/A

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

- [ ] The log appears on the right side of the screen in all primary views.
- [ ] The log remains visible when switching between Bridge, Port, and Captain’s Quarters.
- [ ] Log content, ordering, and behavior are unchanged from before the move.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and observe the log positioned on the right side of the screen.
2. Switch between Bridge, Port, and Captain’s Quarters using the TopBar.
3. Trigger several log events (travel, inspections, UI actions) and confirm they appear correctly and persist across views.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Very long log histories should scroll correctly without resizing or overlap.
- Narrow window resolutions should not obscure core navigation controls.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Requires careful separation between persistent UI and view-specific UI to avoid lifecycle bugs.
- Future UI scaling or layout changes may require revisiting panel width constraints.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0032-feature-persistent-log-panel/`
2) Write this job verbatim to `codex/runs/issue-0032-feature-persistent-log-panel/job.md`
3) Create `codex/runs/issue-0032-feature-persistent-log-panel/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0032-feature-persistent-log-panel`

Codex must write final results only to:
- `codex/runs/issue-0032-feature-persistent-log-panel/results.md`

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
