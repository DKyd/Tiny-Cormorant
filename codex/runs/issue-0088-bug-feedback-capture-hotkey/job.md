# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0088
- Short Title: Feedback capture hotkey does not fire in editor run
- Run Folder Name: issue-0088-bug-feedback-capture-hotkey
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Bug Description
The feedback capture hotkey added in issue-0087 does not reliably trigger during playtesting from the Godot editor. Pressing the configured key either stops the running scene (editor “Stop” shortcut) or produces no capture output at all. As a result, no feedback bundle is generated under `user://feedback/` and the feature is unusable for UAT.

---

## Expected Behavior
When the developer presses the configured capture hotkey during gameplay (including when running from the Godot editor), the game should generate a timestamped feedback bundle under `user://feedback/<YYYY-MM-DD_HH-MM-SS>/` containing the snapshot + log tail files, without stopping the game.

If the feedback capture singleton is unavailable, the game should not stop; it should emit a single dev-only log entry explaining the missing autoload.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Launch the game from the Godot editor (Run Project / F5).
2. While in-game (including while UI panels are open), press the feedback capture hotkey (previously F8; current test key F9).
3. Observe that either the debugging session stops or nothing happens (no capture output).

---

## Observed Output / Error Text
Include exact text if applicable (UI message, error, log line).

- Godot editor output shows: `--- Debugging process stopped ---`
- No feedback folder is created under `user://feedback/`.
- No dev log line appears indicating the hotkey handler fired.

---

## Suspected Area (Optional)
List files/systems you believe are involved.
This is a hint, not a directive.

- `scripts/MainGame.gd` (hotkey / input handling)
- Godot editor shortcut conflict with F8 (“Stop”)
- UI input consumption preventing `_unhandled_input` from firing

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MainGame.gd`
- `project.godot` (InputMap + Autoload entries ONLY if required to fix hotkey reliability)

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

-
-

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Running from the Godot editor, pressing the capture hotkey does **not** stop the debugging session and does **not** close the game.
- [ ] Pressing the capture hotkey reliably generates a new folder under `user://feedback/` containing: `snapshot.json`, `player_log_tail.txt`, `dev_log_tail.txt`, `report.md`.
- [ ] If `/root/FeedbackCapture` is missing (autoload not present), the game continues running and emits exactly one clear dev-only log entry describing the missing autoload.

---

## Regression Checks
List behaviors that must still work after the fix.

- Existing gameplay/UI input interactions still function normally (no broken buttons, typing, or panel interactions).
- No new spam logging is introduced by the hotkey check (one entry per keypress only).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. In the Godot editor, run the project (F5). Open a UI panel (e.g., market) and press the capture hotkey; verify the game does not stop and a feedback bundle is created under `user://feedback/`.
2. Press the capture hotkey again; verify a second timestamped feedback folder is created with all 4 expected files.
3. Temporarily disable/remove the FeedbackCapture autoload (Project Settings ? Autoload), run again, press the capture hotkey, and verify:
   - game continues running
   - a single dev-only log entry indicates the autoload is missing
   - no crash/stop occurs

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
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
