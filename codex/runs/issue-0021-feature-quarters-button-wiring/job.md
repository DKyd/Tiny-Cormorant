# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0021
- Short Title: Wire Captain’s Quarters Button to Panel Overlay
- Run Folder Name: issue-0021-feature-quarters-button-wiring
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Goal
Pressing the existing Captain’s Quarters button opens the Captain’s Quarters UI as an overlay panel without replacing the current view. The panel must close cleanly and preserve the underlying view state.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Captain’s Quarters is a ship-private UI panel, not a location or facility.
- Opening Captain’s Quarters must not replace or reset the active view (Bridge, Port, etc.).
- UI remains read-only with respect to game state; mutations occur only through GameState APIs already implemented.
- No changes to `scenes/MainGame.tscn`.
- No changes to `data/**`.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add or modify FreightDoc logic (handled in Issue-0020).
- Do not add customs, port authority, or enforcement systems.
- Do not implement UI theme or visual polish.
- Do not add new navigation buttons or shortcuts.
- Do not implement save/load behavior.

---

## Context
Issue-0020 introduced the Captain’s Quarters panel UI and GameState APIs for FreightDoc modification and destruction. The game already includes a Captain’s Quarters button at:

`MainGame.tscn ? VBoxContainer/TopBar/QuartersButton`

An earlier attempt to wire this button incorrectly used `_show_view()` to load the panel as a full view. Captain’s Quarters must instead be presented as a panel overlay layered on top of the current view.

What exists:
- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`
- `_on_QuartersButton_pressed()` handler in `scripts/MainGame.gd`

What is missing:
- Correct wiring from the button to instantiate and manage the panel as an overlay.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Update `MainGame.gd` to instance the Captain’s Quarters panel as an overlay UI element.
- Attach the panel to a safe existing UI/root node without modifying `MainGame.tscn`.
- Ensure only one instance of the panel may exist at a time.
- Pressing the Quarters button toggles the panel open/closed.
- The panel’s Close button removes the panel cleanly and clears any references.
- Do not use `_show_view()` for panel presentation.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MainGame.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes
- [x] No

If Yes, list exact new file paths:

- (none)

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

- [ ] Clicking the Captain’s Quarters button opens the Captain’s Quarters panel as an overlay.
- [ ] The active view (Bridge, Port, etc.) remains loaded and unchanged while the panel is open.
- [ ] Clicking the Captain’s Quarters button again closes the panel (no duplicate panels allowed).
- [ ] Clicking the panel’s Close button closes the panel cleanly.
- [ ] No forbidden files were modified, especially `scenes/MainGame.tscn`.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and navigate to Bridge or Port.
2. Click the Captain’s Quarters button; verify the panel appears without changing the view.
3. Interact with the panel UI; confirm the underlying view state is preserved.
4. Click Close on the panel; verify it disappears.
5. Click the Captain’s Quarters button repeatedly; verify it toggles and never spawns duplicates.
6. Switch views (Bridge ? Port) and repeat the test.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Attempting to open the panel when it is already open must not create a second instance.
- If the panel scene fails to load, the game must not crash and should emit a single clear log entry.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- MainGame.gd must locate a suitable overlay host node without changes to MainGame.tscn.
- Future UI refactors may centralize overlay handling; this job should avoid hard-coding fragile node paths.
- UI theme adjustments are intentionally deferred to the human after this job.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0021-feature-quarters-button-wiring/`
2) Write this job verbatim to `codex/runs/issue-0021-feature-quarters-button-wiring/job.md`
3) Create `codex/runs/issue-0021-feature-quarters-button-wiring/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0021-feature-quarters-button-wiring`

Codex must write final results only to:
- `codex/runs/issue-0021-feature-quarters-button-wiring/results.md`

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
