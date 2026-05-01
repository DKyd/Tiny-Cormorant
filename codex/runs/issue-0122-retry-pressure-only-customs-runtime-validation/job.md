# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0122
- Short Title: Retry pressure-only customs runtime validation
- Run Folder Name: issue-0122-retry-pressure-only-customs-runtime-validation
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Retry the live/runtime validation of the pressure-only customs consequence matrix now that `issue-0121` unblocked Godot 4.6.1 startup. Confirm observed runtime behavior for scrutiny escalation, persistence, decay, logs, preview/header surfacing, and no-enforcement boundaries where practical.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- This job must not introduce enforcement, denial, fines, holds, seizures, reputation effects, cargo mutation, credit mutation, document mutation, or travel blocking.
- Desloppify findings remain advisory and must not drive cleanup work during this job.
- Existing preflight, whitelist, review gate, closeout, canonical workspace, and Epiphanes/Physcon handoff rules remain authoritative.

---

## Non-Goals
Hard scope boundaries.

- Do not implement feature, bugfix, refactor, test, Desloppify, or runtime changes.
- Do not modify `scripts/**`, `singletons/**`, `scenes/**`, `data/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot`.
- Do not run Desloppify or any external audit tool.
- Do not create executable future job run folders.
- Do not update the roadmap document in this job.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Phase 3 pressure-only customs consequences and Phase 4 Level 2 documentary audit runtime behavior
- planning horizon: retry the runtime validation blocked in `issue-0120` after the startup fix in `issue-0121`
- decision type: live validation, behavior matrix confirmation, blocker identification, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
`issue-0120` source-confirmed the pressure-only customs model but could not complete live runtime validation because Godot 4.6.1 headless startup failed on the `FeedbackCapture` autoload UID. `issue-0121` fixed that startup blocker by changing the `FeedbackCapture` autoload entry in `project.godot` from UID form to `*res://singletons/FeedbackCapture.gd`.

This job should now retry the runtime validation that `issue-0120` intended: confirm whether current inspection outcomes remain pressure-only, how scrutiny/pressure changes behave under live play, whether decay and persistence can be observed, and whether the next feature job should be Level 2 audit UI surfacing.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define the observed runtime state of pressure-only customs consequences after the startup fix.
- Dependencies and blockers
  - Record any remaining startup, scenario setup, debug-access, or reproduction blockers.
- Candidate job sequence
  - Recommend the next safe jobs based on observed runtime behavior.
- Risk level
  - Classify discovered gaps or follow-up jobs as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely future files for proposed fixes/features, but keep sketches advisory.
- Verification strategy
  - Record exact validation scenarios, commands, setup, expected outcomes, observed outcomes, and pass/fail/blocked status.
- Explicit non-goals for each planned phase
  - Preserve the no-enforcement boundary.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Retry runtime validation using Godot 4.6.1 where practical.
- MUST: Record exact scenario setup, action taken, expected outcome, observed outcome, and pass/fail/blocked status in `results.md`.
- MUST: Confirm whether inspection outcomes remain pressure-only and do not block or punish player actions.
- MUST: Confirm whether scrutiny changes, persistence, and deterministic decay are observable where practical.
- MUST: Record any `.godot/**` churn as forbidden and do not stage it.
- MUST: Recommend follow-up jobs only as advisory candidates.
- MUST NOT: Modify runtime code, scenes, data, documentation, project settings, or governance files during this planning job.
- MUST NOT: introduce or recommend enforcement as the next step unless a later roadmap milestone explicitly authorizes it.
- MUST NOT: treat validation findings as executable scope without a future complete `job.md`.

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

Additional sizing guidance for follow-ups from this validation:
- UI surfacing should be separate from core audit/consequence logic.
- Fixes to pressure escalation, decay, persistence, or depth bias should be separate jobs unless they are inseparable defects in one function.
- Anything touching `singletons/GameState.gd`, `singletons/Customs.gd`, or `scripts/customs/**` is medium-to-high risk and should be narrowly whitelisted.
- If validation succeeds, prefer the next feature job: read-only Level 2 audit surfacing in inspection UI.
- If validation reveals a blocker or defect, prefer a narrow bugfix job before new feature work.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0120` and `issue-0121` results to reuse the intended validation matrix and confirm the startup blocker was resolved.
- Run Godot 4.6.1/headless startup and, where practical, focused runtime scenarios for Level 1/Level 2 inspection outcomes.
- Record a behavior matrix in `results.md` covering classification, scrutiny/pressure effect, persistence, decay, logs, preview/header surfacing, and enforcement absence.
- Recommend whether the next safe governed job should be Level 2 audit UI surfacing or a narrower bugfix/validation follow-up.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/job.md`
- `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/results.md`

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

- `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/job.md`
- `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` includes a runtime validation matrix for relevant Level 1 and Level 2 outcomes, including pass/suspicious/invalid/not-evaluable where practical.
- [ ] `results.md` records scenario setup, action, expected result, observed result, and pass/fail/blocked status for each attempted scenario.
- [ ] `results.md` explicitly confirms whether any validated path causes fines, holds, seizure, denial, travel blocking, reputation effects, cargo mutation, credit mutation, or document mutation.
- [ ] `results.md` documents scrutiny/pressure persistence and deterministic decay observations where practical.
- [ ] `results.md` states whether the `FeedbackCapture` startup blocker remains resolved.
- [ ] `results.md` recommends the next safe governed job and identifies any blockers or ambiguities.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/results.md` and confirm it contains a runtime validation matrix with expected-vs-observed outcomes.
2. Confirm `results.md` states whether pressure-only/no-enforcement boundaries held under runtime validation.
3. Confirm `results.md` states whether the `FeedbackCapture` startup blocker remains resolved.
4. Confirm `results.md` recommends next jobs as advisory candidates only.
5. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
6. Confirm no files under `scripts/**`, `singletons/**`, `scenes/**`, `data/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, `project.godot`, or `codex/jobs/**` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Manual Godot validation may still be blocked by scenario setup limits, lack of debug affordances, or difficulty forcing specific inspection outcomes; record blockers rather than modifying code.
- If Godot/editor launch creates `.godot/**` churn, Codex must not stage it and must report the churn as forbidden.
- If runtime validation cannot be completed in this environment, Codex should provide the best static/manual test plan possible and clearly mark scenarios as blocked.
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
  - `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/**`
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
  - `git commit -m "issue-0122: Retry pressure-only customs runtime validation"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/`
2. Write the job text verbatim to `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/job.md`
3. Create `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0122-retry-pressure-only-customs-runtime-validation`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0122-retry-pressure-only-customs-runtime-validation/results.md`
