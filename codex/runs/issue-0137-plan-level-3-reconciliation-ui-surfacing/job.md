# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0137
- Short Title: Plan Level 3 reconciliation UI surfacing
- Run Folder Name: issue-0137-plan-level-3-reconciliation-ui-surfacing
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Plan how the existing Level 3 read-only reconciliation report should be surfaced in the Customs inspection UI. Define player-facing wording, placement, fallback behavior, finding detail level, no-enforcement language, risks, and the next implementation job without modifying UI or runtime files.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 3 UI surfacing must remain display-only.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No pressure/scrutiny effects, logs, inspection triggers, or enforcement may be introduced.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads may be authorized.

---

## Non-Goals
Hard scope boundaries.

- Do not implement UI surfacing in this job.
- Do not modify scenes, scripts, data, singletons, helper/harness files, project settings, documentation roadmap files, or governance files.
- Do not change Level 3 helper semantics or integration behavior.
- Do not add pressure effects, logs, new triggers, or enforcement.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Level 3 read-only reconciliation display in Customs inspection UI
- planning horizon: define the first future UI implementation job after report attachment
- decision type: UI placement, player-facing language, fallback behavior, detail level, risk assessment, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
`issue-0136` attached `report["level3_reconciliation"]` to customs inspection reports only when `max_depth >= 3`, with no UI, pressure, logs, or enforcement. `issue-0123` previously added Level 2 documentary audit details to the existing Customs inspection panel. The player can reach that panel through:

`Main Menu -> New Game -> Bridge -> Port -> Customs`

The next safe feature step is to surface the existing Level 3 report in that inspection UI, but wording and placement matter. Level 3 may frequently return `not_evaluable` for container/tare checks until container class metadata exists, and the UI must not imply fines, seizure, physical inspection, or enforcement.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what Level 3 UI surfacing means and what it does not mean.
- Dependencies and blockers
  - Identify relevant UI files, report fields, missing-data limitations, and manual validation constraints.
- Candidate job sequence
  - Recommend the next governed UI implementation job and later follow-ups.
- Risk level
  - Classify each candidate job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely UI scene/script files and whether any formatter/helper files should be allowed.
- Verification strategy
  - Define how future UI work proves display-only behavior and handles clean/suspicious/not-evaluable reports.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement, no-pressure, no-log, and no-helper-semantics-change boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat Level 3 UI surfacing as display-only.
- MUST: Use player-facing language that communicates documentary/runtime reconciliation without implying enforcement.
- MUST: Show safe fallback text when `level3_reconciliation` is absent, malformed, or `not_evaluable`.
- MUST: Separate UI surfacing from helper semantics, integration, pressure effects, and enforcement.
- MUST: Preserve existing Level 1 and Level 2 inspection UI behavior.
- MUST NOT: modify UI, runtime, data, or helper files in this planning job.
- MUST NOT: introduce warnings that imply cargo seizure, holds, fines, physical search, or travel denial.
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

Additional sizing guidance for Level 3 UI:
- UI surfacing should be separate from pressure/scrutiny effects.
- UI surfacing should be separate from helper output semantics.
- UI surfacing should be separate from container-class metadata generation.
- Prefer modifying only the existing Customs inspection panel scene/script if practical.
- If a reusable audit display subpanel is needed, plan it as a separate job unless the UI change is otherwise unworkable.
- Avoid broad layout redesign or visual polish in the first surfacing job.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0123`, `issue-0135`, and `issue-0136` results to understand current UI and report shape.
- Inspect existing Customs inspection panel scene/script read-only to identify placement and likely future whitelist.
- Define display copy for `clean`, `suspicious`, `not_evaluable`, missing, and malformed Level 3 reports.
- Write `results.md` with recommended UI implementation job, likely whitelist, risks, fallback behavior, and verification strategy.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/job.md`
- `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/results.md`

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

- `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/job.md`
- `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` defines recommended UI placement for Level 3 reconciliation output.
- [ ] `results.md` defines player-facing wording for clean, suspicious, not-evaluable, absent, and malformed reports.
- [ ] `results.md` defines how many findings/details to show and how to handle long/missing data.
- [ ] `results.md` proposes the next UI implementation job with job type, risk level, likely whitelist, narrow goal, and verification approach.
- [ ] `results.md` preserves no-enforcement, no-pressure, no-log, and no-helper-semantics-change boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/results.md` and confirm it defines UI placement and wording.
2. Confirm `results.md` includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
3. Confirm `results.md` defers pressure effects, enforcement, helper changes, and visual polish.
4. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
5. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 3 reports may often be `not_evaluable` until container class metadata exists; UI should make that understandable without implying a bug.
- The first UI surfacing job should not attempt a full UI polish pass.
- If existing panel layout cannot safely accommodate Level 3 output, recommend a narrower UI structure job rather than guessing.
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
  - `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/**`
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
  - `git commit -m "issue-0137: Plan Level 3 reconciliation UI surfacing"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/`
2. Write the job text verbatim to `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/job.md`
3. Create `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0137-plan-level-3-reconciliation-ui-surfacing`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0137-plan-level-3-reconciliation-ui-surfacing/results.md`
