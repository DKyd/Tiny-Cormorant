```markdown
# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0132
- Short Title: Triage Godot headless validation crash
- Run Folder Name: issue-0132-triage-godot-headless-validation-crash
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Triage the recurring Godot 4.6.1 headless signal 11 crash that is blocking useful direct-call/runtime validation. Determine whether it appears environment-only, headless-only, project-startup-related, or tied to a specific project surface, and recommend the next governed job or validation strategy.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- No project settings, runtime code, scenes, data, governance files, or validation harness files may be modified.
- Level 3 helper remains unintegrated and unwired.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- No enforcement may be introduced.

---

## Non-Goals
Hard scope boundaries.

- Do not fix the crash in this job.
- Do not modify `project.godot`, `.godot/**`, runtime code, scenes, data, scripts, singletons, documentation, or governance files.
- Do not integrate or modify `CustomsLevel3Reconciliation.gd`.
- Do not add a validation harness.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: validation infrastructure / Godot headless startup reliability
- planning horizon: unblock future Level 3 helper validation and safe integration work
- decision type: crash triage, reproduction characterization, validation strategy recommendation, and next-job selection

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
Recent jobs reported Godot 4.6.1 headless crashes with signal 11:

- `issue-0126`: headless smoke check crashed with signal 11, making runtime parse/startup verification inconclusive.
- `issue-0131`: headless crashed with signal 11 again before useful direct-call validation of `CustomsLevel3Reconciliation`.

Earlier `issue-0121` fixed a `FeedbackCapture` autoload UID startup blocker, and `issue-0122` confirmed startup reached normal early boot and contract generation without the prior UID error. The current signal 11 appears to be a separate blocker. Before integrating Level 3 reconciliation into any live path, the project needs a clear validation strategy or a separate bugfix if the crash is project-caused.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what “usable validation path” means for upcoming Level 3 work.
- Dependencies and blockers
  - Identify whether headless Godot is blocked, whether normal editor/game launch is affected, and what evidence exists.
- Candidate job sequence
  - Recommend whether the next job should be a bugfix, harness planning, harness implementation, or feature continuation.
- Risk level
  - Classify the crash and recommended next jobs as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files if a bugfix or validation harness is recommended.
- Verification strategy
  - Record exact commands, outputs, environment assumptions, and alternate validation routes.
- Explicit non-goals for each planned phase
  - Preserve no-runtime-change and no-feature-integration boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Record exact Godot command(s) attempted and observed output/error text.
- MUST: Distinguish between headless-only crash, normal editor/game crash, and project startup failure where practical.
- MUST: Record whether `.godot/**` churn appears and ensure it is not staged.
- MUST: Recommend a next governed job or alternate validation strategy based on evidence.
- MUST: Keep Level 3 helper unintegrated during this triage.
- MUST NOT: modify runtime code, project settings, data, scenes, scripts, singletons, documentation, governance files, or `.godot/**`.
- MUST NOT: chase a speculative fix without a separate bugfix job.
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

Additional sizing guidance for validation-crash follow-ups:
- If the crash is project-startup-related, use a narrow bugfix job with the smallest possible whitelist.
- If the crash is headless-only/environment-only, prefer documenting a non-headless validation path or a lightweight direct-call harness.
- If a harness is needed, plan it separately from Level 3 feature integration.
- Do not combine crash fixing, harness creation, and Level 3 integration in one job.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0121`, `issue-0122`, `issue-0126`, and `issue-0131` results for prior startup/crash evidence.
- Attempt only read-only/launch validation commands that do not require repo edits, recording exact commands and outputs.
- Check whether any `.godot/**` churn or other working-tree changes appear after launch attempts, and do not stage them.
- Write `results.md` with crash characterization, evidence, blockers, recommended validation strategy, and next governed job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0132-triage-godot-headless-validation-crash/job.md`
- `codex/runs/issue-0132-triage-godot-headless-validation-crash/results.md`

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

- `codex/runs/issue-0132-triage-godot-headless-validation-crash/job.md`
- `codex/runs/issue-0132-triage-godot-headless-validation-crash/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` records exact Godot command(s) attempted and observed output/error text.
- [ ] `results.md` states whether the crash appears headless-only, environment-only, project-startup-related, or unresolved.
- [ ] `results.md` records whether normal editor/game launch was checked or why it was not practical.
- [ ] `results.md` records whether `.godot/**` churn or other working-tree changes appeared after attempts.
- [ ] `results.md` recommends the next governed job or alternate validation strategy with risk level, likely whitelist, narrow goal, and verification approach.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0132-triage-godot-headless-validation-crash/results.md` and confirm exact commands and outputs are recorded.
2. Confirm `results.md` characterizes the crash and recommends a next governed step.
3. Confirm `results.md` states whether `.godot/**` churn appeared.
4. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
5. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, `project.godot`, or `codex/jobs/**` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Signal 11 may be a Godot engine/headless/environment issue rather than a project bug; do not assume without evidence.
- Launching Godot may create editor metadata churn; it must not be staged and should be reported if it appears.
- If a normal editor launch requires visible GUI interaction, Codex should stop or record that it was not practical rather than using unauthorized GUI actions.
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
  - `codex/runs/issue-0132-triage-godot-headless-validation-crash/**`
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
  - `git commit -m "issue-0132: Triage Godot headless validation crash"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0132-triage-godot-headless-validation-crash/`
2. Write the job text verbatim to `codex/runs/issue-0132-triage-godot-headless-validation-crash/job.md`
3. Create `codex/runs/issue-0132-triage-godot-headless-validation-crash/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0132-triage-godot-headless-validation-crash`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0132-triage-godot-headless-validation-crash/results.md`
```
