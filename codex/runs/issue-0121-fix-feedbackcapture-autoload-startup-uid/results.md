# Results

## Root Cause Summary
- `project.godot` registered `FeedbackCapture` as an autoload using a UID-form reference:
  - `FeedbackCapture="*uid://djwab4xr50ujm"`
- In Godot 4.6.1 headless startup, that UID-form autoload failed to resolve even though `singletons/FeedbackCapture.gd.uid` existed.
- The failure observed during `issue-0120` was:
  - `ERROR: Unrecognized UID: "uid://djwab4xr50ujm".`
  - `ERROR: Resource file not found: res:// (expected type: unknown)`
  - `ERROR: Failed to instantiate an autoload, can't load from path: .`
- The bug was therefore the autoload reference format in `project.godot`, not a missing script file or a parse failure in `singletons/FeedbackCapture.gd`.

## Fix Summary
- Replaced the `FeedbackCapture` autoload entry in `project.godot` with the explicit script path used by the rest of the project autoloads:
  - from `*uid://djwab4xr50ujm`
  - to `*res://singletons/FeedbackCapture.gd`
- No script logic changes were required.
- This preserved `FeedbackCapture` as an autoload singleton while avoiding the failing UID resolution path during headless startup.

## Files Changed (and why)
- `project.godot`
  - changed only the `FeedbackCapture` autoload registration from UID form to explicit `res://` script path.
- `codex/runs/ACTIVE_RUN.txt`
  - set active run to `issue-0121-fix-feedbackcapture-autoload-startup-uid`.
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/job.md`
  - recorded the provided bugfix job spec verbatim.
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/results.md`
  - recorded root cause, fix, tests, and regression checks.

## Manual Tests Performed
- Reproduced the project autoload configuration before the fix by confirming `project.godot` used:
  - `FeedbackCapture="*uid://djwab4xr50ujm"`
- Re-ran the same headless validation command used during `issue-0120` after the fix:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant' --quit-after 5 --log-file 'C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant\codex\runs\issue-0121-fix-feedbackcapture-autoload-startup-uid\godot-headless.log'
```

- Observed result after the fix:
  - headless startup completed its early boot window without the prior `FeedbackCapture` autoload UID error
  - console output advanced into normal project startup and contract generation
  - no `FeedbackCapture` parse error was emitted
- Verified afterward:
  - `git status --short` showed only whitelisted job changes
  - no `.godot/**` churn appeared

## Regression Checks Performed
- Confirmed `project.godot` still lists all expected autoloads:
  - `CommodityDB`
  - `Galaxy`
  - `GameState`
  - `Economy`
  - `Contracts`
  - `Log`
  - `Customs`
  - `FeedbackCapture`
- Confirmed the project main scene remains:
  - `run/main_scene="res://scenes/MainMenu.tscn"`
- Confirmed `singletons/FeedbackCapture.gd` still exists and was left unchanged.
- Confirmed the fix was limited to the smallest necessary autoload path correction.
- Confirmed no `.godot/**` files were modified, staged, or committed.

## Remaining Risks or Follow-Ups
- This fix addresses the `FeedbackCapture` autoload startup failure specifically. It does not by itself provide a full deterministic gameplay validation harness for customs scenarios.
- A follow-up runtime-validation job can now retry the blocked live checks from `issue-0120` using the same headless startup path or a manual Godot session.
