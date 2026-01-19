# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0039
- Short Title: In-Session Menu (Escape) with Save/Settings Placeholders
- Run Folder Name: issue-0039-feature-in-session-menu-escape
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Add an in-session menu that can be opened with the Escape key during gameplay. The menu provides session-level actions (Resume, Quit to Main Menu, Quit to Desktop) and includes Save and Settings buttons as visible placeholders (not hooked up yet).

This establishes the in-session “pause/session menu” surface without introducing persistence, enforcement, or UI authority violations.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via `GameState`.
- Views inside gameplay still swap via `_show_view()` in `MainGame.gd`; the in-session menu does not replace this navigation.
- No save/load persistence is added; Save is a placeholder only.
- No settings system is added; Settings is a placeholder only.
- No per-frame or loop-driven log spam is introduced; opening/closing the menu is UI-only and should not log.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- No actual save/load implementation.
- No settings implementation (audio/video/keybinds/etc.).
- No time or economy behavior changes beyond pausing input as needed for the menu.
- No changes to `data/**`.
- No modifications to `scenes/MainGame.tscn`.

---

## Context
The project now boots into a Main Menu (Issue-0038). Once in gameplay (MainGame), the player currently has no “session menu” accessible during play.

We need an in-session menu accessible via Escape that:
- overlays on top of gameplay
- does not mutate gameplay state directly
- provides clear session exit paths
- provides future affordances (Save, Settings) without implementing them yet

---

## Standard Behavior (Authoritative)
- Pressing `Esc` while in gameplay toggles the in-session menu:
  - If closed ? open
  - If open ? close (Resume)
- While the in-session menu is open:
  - gameplay input beneath it is blocked
  - view navigation should not change unless a menu action is clicked
- Buttons:
  - Resume: closes the in-session menu
  - Save: visible but disabled OR shows “Not implemented” status text (no persistence)
  - Settings: visible but disabled OR shows “Not implemented” status text
  - Quit to Main Menu: returns to `MainMenu` scene
  - Quit to Desktop: quits application

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries, not specific code structure.

- Add a new in-session menu scene (overlay UI) with the required buttons and a small status label for placeholder feedback.
- Add minimal input handling in `MainGame.gd` to toggle the overlay on Escape.
- Ensure the overlay blocks underlying input while visible.
- Implement Quit actions via scene change / tree quit.
- Keep Save/Settings as placeholders: disabled or produce non-invasive status text (no side effects).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MainGame.gd`
- `scenes/ui/InSessionMenu.tscn` (new)
- `scripts/ui/InSessionMenu.gd` (new)

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

- `scenes/ui/InSessionMenu.tscn`
- `scripts/ui/InSessionMenu.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None (signals from the menu to MainGame are allowed but should remain private to the feature)

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

- [ ] Pressing Escape during gameplay opens the in-session menu overlay; pressing Escape again closes it.
- [ ] While the menu is open, gameplay UI beneath it does not receive input (menu blocks interaction).
- [ ] Resume closes the menu.
- [ ] Quit to Main Menu returns to `res://scenes/MainMenu.tscn`.
- [ ] Quit to Desktop exits the application.
- [ ] Save and Settings are present and clearly non-functional (disabled or show “Not implemented” feedback) and cause no state mutation.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start game ? New Game ? enter gameplay.
2. Press Esc ? confirm in-session menu appears over gameplay.
3. Attempt to click underlying UI elements while menu is open ? confirm they do not respond.
4. Press Esc or click Resume ? menu closes.
5. Open menu ? click Save ? confirm it is disabled or shows “Not implemented” feedback only.
6. Open menu ? click Settings ? confirm it is disabled or shows “Not implemented” feedback only.
7. Open menu ? click Quit to Main Menu ? confirm Main Menu loads.
8. From gameplay again, open menu ? click Quit to Desktop ? confirm application exits.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Rapidly pressing Esc should not create duplicate overlays or multiple instances.
- If the menu is open and the player changes view (Bridge/Port/Quarters) via TopBar, the menu should remain stable (prefer closing it or blocking navigation; choose one and keep it consistent).
- Scene change failures should not crash silently (log an error or fail safely).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Avoid adding logs for menu open/close (UI-only). Only log meaningful session exits if desired.
- Ensure overlay input blocking is reliable; do not rely on per-frame hacks.
- Keep Save/Settings placeholders non-invasive to avoid accidental persistence expectations.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0039-feature-in-session-menu-escape/`
2) Write this job verbatim to `codex/runs/issue-0039-feature-in-session-menu-escape/job.md`
3) Create `codex/runs/issue-0039-feature-in-session-menu-escape/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0039-feature-in-session-menu-escape`

Codex must write final results only to:
- `codex/runs/issue-0039-feature-in-session-menu-escape/results.md`

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
