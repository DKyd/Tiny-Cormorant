# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0038
- Short Title: Session Framing Main Menu Skeleton
- Run Folder Name: issue-0038-feature-session-framing-main-menu
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Add a minimal Main Menu flow that frames a “session/run” for Tiny Cormorant: the player can start a new game and quit cleanly, without introducing persistence or changing core gameplay behavior.

The menu should be functional, lightweight, and provide a stable entry point for future save/load work.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via `GameState`.
- Views inside gameplay still swap via `_show_view()` in `MainGame.gd`.
- No save/load or persistence semantics are introduced.
- No gameplay behavior changes (contracts, inspections, time, economy) beyond starting a fresh session when requested.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- No Save/Load UI, no persistence, no Continue-from-save.
- No enforcement systems (fines, seizures, reputation, legality).
- No redesign of existing TopBar navigation or view lifecycle rules.
- No changes to `data/**` or other protected assets.

---

## Context
Currently the project boots directly into gameplay (MainGame) without a menu, which makes it difficult to define what a “session” is and where future persistence will live.

A minimal Main Menu provides:
- a clear entry point (New Game)
- a clean exit path (Quit)
- optional stub affordances for future features (e.g., disabled Continue)

This job should not alter existing gameplay UI architecture: once in MainGame, the Bridge/Port/Quarters navigation and persistent log behavior remain unchanged.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries, not specific code structure.

- Create a new Main Menu scene with simple buttons: New Game and Quit (optional Continue disabled with “TODO” text).
- Route New Game to load the existing MainGame scene as the gameplay entry point.
- Ensure New Game produces a fresh session state by invoking the existing initialization path (no partial carryover).
- Keep menu logic isolated to the menu scene/script; avoid touching gameplay UI scripts except for minimal entry wiring.
- Add clear log entry only if starting a session is an explicit player action already logged elsewhere; otherwise do not introduce log spam.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/MainMenu.tscn` (new)
- `scripts/MainMenu.gd` (new)
- `project.godot` (to set main scene, if required)
- `scripts/MainGame.gd` (only if strictly necessary to support a clean “new session” entry path)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `scenes/MainMenu.tscn`
- `scripts/MainMenu.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None (prefer using existing initialization flows; if a new “reset session” method is absolutely required, document it here and keep it minimal)

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

- [ ] Game launches into a Main Menu scene.
- [ ] Clicking “New Game” reliably loads gameplay (MainGame) and starts a fresh session.
- [ ] Clicking “Quit” cleanly exits the application.
- [ ] No save/load or persistence UI is present (Continue, if present, is disabled/non-functional).
- [ ] Once in gameplay, existing navigation (Bridge/Port/Quarters) and log behavior are unchanged.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Run the project and confirm the first screen is the Main Menu.
2. Click “New Game” and confirm you enter gameplay normally.
3. Use TopBar navigation to switch Bridge/Port/Quarters and confirm behavior is unchanged.
4. Return to Main Menu (if not implemented, stop the run) and run again; confirm menu still appears first.
5. Click “Quit” and confirm the game exits.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Rapidly clicking “New Game” multiple times should not crash or create double instances (button should disable or guard after first press).
- If MainGame fails to load (missing resource path), menu should not hard-crash silently (log an error or fail gracefully).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Setting `project.godot` main scene is a project-level change; keep it minimal and verify in-editor and export runs.
- Ensure “fresh session” semantics do not accidentally depend on persistence; prefer existing initialization rather than inventing partial resets.
- Avoid adding menu-driven logging that creates noise; only log meaningful player actions.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0038-feature-session-framing-main-menu/`
2) Write this job verbatim to `codex/runs/issue-0038-feature-session-framing-main-menu/job.md`
3) Create `codex/runs/issue-0038-feature-session-framing-main-menu/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0038-feature-session-framing-main-menu`

Codex must write final results only to:
- `codex/runs/issue-0038-feature-session-framing-main-menu/results.md`

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
