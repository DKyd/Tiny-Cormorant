# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0134
- Short Title: Run Level 3 helper validation harness
- Run Folder Name: issue-0134-run-level-3-helper-validation-harness
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Run the deterministic Level 3 helper validation harness added in `issue-0133` using the known Godot 4.6.1 executable path. Record exact commands, outputs, pass/fail status, determinism evidence, and any blockers before Level 3 helper integration is considered.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- `CustomsLevel3Reconciliation` and its validation harness must remain unintegrated with live Customs/GameState/UI paths.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No enforcement may be introduced.
- No `.godot/**` churn may be staged or committed.

---

## Non-Goals
Hard scope boundaries.

- Do not modify the helper or validation harness in this job.
- Do not add integration into `Customs.gd`, `GameState.gd`, inspections, UI, logs, pressure, save/load, or gameplay.
- Do not modify runtime code, scenes, data files, documentation roadmap files, project settings, or governance files.
- Do not add a broad test framework.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Level 3 helper validation
- planning horizon: validate standalone helper behavior before any live integration
- decision type: validation execution, pass/fail evidence, blocker identification, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
`issue-0131` implemented `scripts/customs/CustomsLevel3Reconciliation.gd` as a pure static read-only helper. `issue-0133` added `scripts/customs/CustomsLevel3ReconciliationValidation.gd`, a narrow direct-call validation harness covering clean, mismatch, missing docs, missing cargo, unknown commodity/mass, missing tolerance policy, missing container class, and repeated-run determinism.

Physcon could not execute the harness in `issue-0133` because `godot` was not on PATH and no executable was found in common searched locations. The human has now provided the Godot executable path:

`C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe`

The OneDrive project folder should be fully local/hydrated via “Always keep on this device.”

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - State whether the standalone Level 3 helper is validated enough for a future integration-planning job.
- Dependencies and blockers
  - Record Godot executable/path issues, OneDrive hydration issues, crashes, parse errors, or harness failures.
- Candidate job sequence
  - Recommend the next governed job based on harness outcome.
- Risk level
  - Classify any remaining blocker or next job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files for any future bugfix or integration job.
- Verification strategy
  - Record exact command(s), output, pass/fail status, determinism evidence, and working-tree state.
- Explicit non-goals for each planned phase
  - Preserve no-integration, no-pressure, no-UI, and no-enforcement boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Use the provided Godot executable path unless it is unavailable.
- MUST: Record the exact command and output in `results.md`.
- MUST: Record whether the harness passes, fails, crashes, or is blocked.
- MUST: Record whether repeated-run determinism was validated by the harness.
- MUST: Check and report working-tree status after running Godot.
- MUST: Do not stage or commit `.godot/**` churn if it appears.
- MUST NOT: modify helper, harness, runtime code, project settings, data, scenes, documentation, or governance files in this planning job.
- MUST NOT: integrate Level 3 helper into live gameplay based on this job alone.
- MUST NOT: treat this planning output as executable scope without a future complete `job.md`.

---

## Safe Job Sizing (Mandatory)
Planning jobs must include safe job sizing guidance for future executable work.

Split planned work when any of the following are true:
- it crosses job type boundaries
- it changes multiple independent player-visible behaviors
- it mixes refactor with feature implementation
- it needs a broad whitelist across unrelated files or systems
- it would be hard to review confidently in one staged diff
- it lacks a clear verification strategy

For each proposed executable job, record where practical:
- target job type
- risk level: low, medium, or high
- likely whitelist
- narrow goal
- verification approach

Additional sizing guidance after validation:
- If harness passes, the next job may plan or implement narrow read-only integration, but not UI/pressure/enforcement at the same time.
- If harness fails because of helper behavior, recommend a narrow bugfix job limited to `scripts/customs/CustomsLevel3Reconciliation.gd` and active run files.
- If harness fails because of validation harness behavior, recommend a narrow bugfix job limited to `scripts/customs/CustomsLevel3ReconciliationValidation.gd` and active run files.
- If Godot crashes or cannot run, recommend tooling/environment triage rather than feature integration.
- Do not combine helper bugfix, harness bugfix, and integration in one job.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Confirm the Godot executable exists at `C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe`.
- Run the Level 3 validation harness using the provided executable path, recording exact command and output.
- Check `git status --short` after the run and report any `.godot/**` or other churn without staging forbidden files.
- Write `results.md` with pass/fail/blocker status, determinism evidence, and next-job recommendation.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0134-run-level-3-helper-validation-harness/job.md`
- `codex/runs/issue-0134-run-level-3-helper-validation-harness/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files or directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**`
- `.godot/**`
- `.desloppify/**`
- `Documentation/**`
- `project.godot`
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

- `codex/runs/issue-0134-run-level-3-helper-validation-harness/job.md`
- `codex/runs/issue-0134-run-level-3-helper-validation-harness/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` records whether `C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe` exists and was used.
- [ ] `results.md` records exact validation command(s) and output.
- [ ] `results.md` records harness pass/fail/crash/blocked status.
- [ ] `results.md` records determinism evidence from repeated-run validation if available.
- [ ] `results.md` records working-tree status after the Godot run and whether `.godot/**` churn appeared.
- [ ] `results.md` recommends the next governed job based on validation outcome.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified or staged.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0134-run-level-3-helper-validation-harness/results.md` and confirm exact command/output and pass/fail status are recorded.
2. Confirm `results.md` states whether determinism validation passed.
3. Confirm `results.md` records post-run working-tree status and any `.godot/**` churn.
4. Confirm `results.md` recommends the next governed job.
5. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
6. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Running Godot may create `.godot/**` churn; do not stage it.
- If Godot crashes, record exact error and recommend tooling/environment triage rather than continuing feature integration.
- If the harness cannot be executed without modifying project settings or adding autoloads/scenes, stop and report.
- If the OneDrive folder is not fully hydrated, the human may need to reapply “Always keep on this device.”
- If the canonical path resolves through OneDrive on this machine, record any path-governance ambiguity only as a follow-up note; do not modify governance files in this job.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Handoff Protocol (Mandatory)
- The human is the final authority for priority, approval, and scope.
- Epiphanes is the planning and orientation Codex by default unless the human explicitly assigns it implementation authority for a specific job.
- Physcon is the execution Codex for canonical-clone work by default unless the human explicitly assigns execution elsewhere.
- Planning notes, roadmap entries, candidate job lists, and milestone maps are non-executable unless converted into a complete future `job.md` or explicitly authorized active-run instructions.
- If a prompt is ambiguous, incomplete, or mixes planning advice with implementation instructions, Codex must stop and ask before starting executable work.

---

## Canonical Workspace Rule (Mandatory)
- Codex must treat `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` as the canonical local Tiny Cormorant workspace unless the human explicitly names another path for the current job.
- If Codex detects a non-canonical Tiny Cormorant clone, it must warn and stop until the human confirms that alternate path.
- Older scratch clones, including `Documents/Codex`, must not be used as the default working copy.

---

## Git Preflight Gate (Mandatory)
Before any code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty because of modified, staged, or untracked files, Codex must stop and ask the human to resolve the stop condition.
- If `git status -sb` shows the branch is behind origin, Codex must stop and instruct `git pull --ff-only` after any required cleanup.
- Codex must not proceed with implementation until the working tree is clean and the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage only:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0134-run-level-3-helper-validation-harness/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- Stop and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex must auto-run closeout immediately.
- Stop conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside `ACTIVE_RUN.txt`, this run folder, or the job whitelist.
  - Scope, whitelist, or blacklist instructions conflict or are ambiguous.
- Run:
  - `git commit -m "issue-0134: Run Level 3 helper validation harness"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0134-run-level-3-helper-validation-harness/`
2. Write the job text verbatim to `codex/runs/issue-0134-run-level-3-helper-validation-harness/job.md`
3. Create `codex/runs/issue-0134-run-level-3-helper-validation-harness/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0134-run-level-3-helper-validation-harness`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0134-run-level-3-helper-validation-harness/results.md`
