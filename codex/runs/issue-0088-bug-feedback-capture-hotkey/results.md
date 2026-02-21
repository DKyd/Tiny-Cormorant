# issue-0088 Results

## Root Cause Summary
- Feedback capture was handled in `MainGame._unhandled_input`, which only runs after controls decline events. During editor playtests (especially with UI panels open), key events can be consumed before `_unhandled_input` runs, so capture never fired.
- The handler also emitted an extra dev line (`DEV: F9 pressed...`), which conflicted with the requirement to log only one clear missing-autoload message when `/root/FeedbackCapture` is unavailable.

## Fix Summary
- Moved capture trigger handling to `MainGame._input` so it runs before UI consumption and reliably catches the hotkey during gameplay/editor runs.
- Added a small resolver:
  - Prefer configured InputMap action `feedback_capture` when present.
  - Fallback to `F9` keypress when the action is not defined.
- Removed the extra debug "hotkey pressed" log and kept a single dev-only missing-autoload log line.
- Kept ESC/in-session menu logic in `_unhandled_input` unchanged.

## Files Changed (and Why)
- `scripts/MainGame.gd`
  - Added `FEEDBACK_CAPTURE_ACTION` constant.
  - Added `_input(event)` capture handling for reliable hotkey detection.
  - Added `_try_feedback_capture()` helper to centralize capture/missing-autoload behavior.
  - Removed feedback capture handling from `_unhandled_input` to avoid UI-consumption misses.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0088-bug-feedback-capture-hotkey` per job scaffolding requirement.
- `codex/runs/issue-0088-bug-feedback-capture-hotkey/job.md`
  - Added verbatim job definition per scaffolding requirement.
- `codex/runs/issue-0088-bug-feedback-capture-hotkey/results.md`
  - Added this results report per scaffolding requirement.

## Manual Tests Performed
- Not executed in this environment (no Godot editor runtime available in this shell session).

## Regression Checks Performed
- Static review only:
  - ESC menu toggle path in `_unhandled_input` remains intact.
  - Hotkey path now logs only one entry when autoload is missing.
- Runtime UI/gameplay regression checks were not executed in-editor in this environment.

## Remaining Risks or Follow-ups
- Verify in Godot editor that `feedback_capture` action exists in Project Settings if you want configurable remapping; fallback `F9` is active when action is missing.
- Run the manual test plan in-editor to confirm bundle creation (`snapshot.json`, `player_log_tail.txt`, `dev_log_tail.txt`, `report.md`) and missing-autoload behavior.
