# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0121
- Short Title: Fix FeedbackCapture autoload startup UID
- Run Folder Name: issue-0121-fix-feedbackcapture-autoload-startup-uid
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Bug Description
Godot 4.6.1 headless startup fails while loading the `FeedbackCapture` autoload from `project.godot`. This blocks runtime validation jobs such as `issue-0120`, even though the repository remains clean after the launch attempt.

The current autoload entry is:

`FeedbackCapture="*uid://djwab4xr50ujm"`

The corresponding UID file exists at `singletons/FeedbackCapture.gd.uid`, but the UID-based autoload reference appears to fail during headless startup.

---

## Expected Behavior
The project should boot in Godot 4.6.1/headless without failing on the `FeedbackCapture` autoload. The `FeedbackCapture` singleton should remain registered and existing feedback-capture behavior should remain available.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Use the canonical clone: `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`.
2. Run the project startup/headless validation command used during `issue-0120`.
3. Observe startup failure while resolving the `FeedbackCapture` autoload UID from `project.godot`.

---

## Observed Output / Error Text
Include exact text if applicable (UI message, error, log line).

Exact error text should be copied from the `issue-0120` validation output if available. The known observed failure is that Godot 4.6.1 headless boot fails on the `FeedbackCapture` autoload UID in `project.godot`.

---

## Suspected Area (Optional)
List files/systems you believe are involved.
This is a hint, not a directive.

- `project.godot` autoload entry for `FeedbackCapture`
- `singletons/FeedbackCapture.gd`
- `singletons/FeedbackCapture.gd.uid`

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Prefer the smallest fix that preserves the autoload and allows Godot 4.6.1/headless startup.
- Do not change any gameplay, UI, customs, economy, inspection, or save/load behavior.
- Do not stage or commit `.godot/**` editor churn.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `project.godot`
- `singletons/FeedbackCapture.gd` only if strictly required
- `singletons/FeedbackCapture.gd.uid` only if strictly required
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/job.md`
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**` except `singletons/FeedbackCapture.gd` and `singletons/FeedbackCapture.gd.uid`
- `.godot/**`
- `.desloppify/**`
- `Documentation/**`
- `codex/AGENTS.md`
- `codex/README.md`
- `codex/CONTEXT.md`
- `codex/jobs/**`
- `codex/tools/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/job.md`
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/results.md`

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Godot 4.6.1/headless startup no longer fails on the `FeedbackCapture` autoload.
- [ ] `FeedbackCapture` remains registered as an autoload singleton.
- [ ] The fix is limited to the smallest necessary autoload/UID/path correction.
- [ ] No `.godot/**` files are staged or committed.
- [ ] No gameplay, customs, economy, inspection, UI, data, or save/load behavior is changed.

---

## Regression Checks
List behaviors that must still work after the fix.

- Existing autoloads remain registered: `CommodityDB`, `Galaxy`, `GameState`, `Economy`, `Contracts`, `Log`, `Customs`, and `FeedbackCapture`.
- Project main scene remains `res://scenes/MainMenu.tscn`.
- `FeedbackCapture` script still loads without parse errors.
- Runtime validation can proceed far enough to reach normal project startup rather than failing during autoload resolution.
- Working tree remains clean after closeout except for no staged/unstaged `.godot/**` churn.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Open the canonical project in Godot 4.6.1 from `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant\project.godot`.
2. Confirm the project loads without an autoload UID error for `FeedbackCapture`.
3. Confirm Project Settings > Autoload still lists `FeedbackCapture`.
4. Run the same headless startup command used during `issue-0120` and confirm the startup reaches normal completion or the next unrelated runtime state without failing on `FeedbackCapture`.
5. Run `git status --short` and confirm no `.godot/**` churn is present or staged.

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage → staged diff review → commit → push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/**, or job whitelist.
  - `.godot/**` editor churn is present.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0121: Fix FeedbackCapture autoload startup UID"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/`
2) Write this job verbatim to `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/job.md`
3) Create `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0121-fix-feedbackcapture-autoload-startup-uid`

Codex must write final results only to:
- `codex/runs/issue-0121-fix-feedbackcapture-autoload-startup-uid/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
