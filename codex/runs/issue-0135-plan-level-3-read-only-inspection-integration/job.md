# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0135
- Short Title: Plan Level 3 read-only inspection integration
- Run Folder Name: issue-0135-plan-level-3-read-only-inspection-integration
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Plan how the validated Level 3 read-only reconciliation helper should be integrated into inspection reports without changing pressure, UI, logs, enforcement, or Level 2 behavior. Define the integration seam, trigger/depth boundary, context shape, output attachment, risks, verification strategy, and candidate implementation job.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- Level 3 integration must remain read-only and report-only in the future implementation plan.
- No pressure/scrutiny effects, UI surfacing, logs, or enforcement may be introduced by this planning job.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads may be authorized.

---

## Non-Goals
Hard scope boundaries.

- Do not implement Level 3 integration in this job.
- Do not modify `Customs.gd`, `GameState.gd`, helper/harness files, data files, scenes, UI, documentation roadmap files, project settings, or governance files.
- Do not add pressure effects, UI surfacing, log output, inspection triggers, scenario harness changes, or enforcement.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Level 3 read-only reconciliation report integration into customs inspection output
- planning horizon: define the first future implementation job that attaches existing helper output to inspection reports
- decision type: integration seam planning, depth/trigger boundary, context ownership, risk assessment, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
The Level 3 foundation is now in place and remains unwired:

- `issue-0126`: added inert `customs_mass_per_unit` commodity data.
- `issue-0128`: added inert `CustomsReconciliationDB` container/tolerance data.
- `issue-0129`: added read-only primitive accessors.
- `issue-0131`: implemented `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)`.
- `issue-0133`: added a deterministic direct-call validation harness.
- `issue-0134`: ran the harness twice with Godot 4.6.1; both runs exited `0`.

The next feature step should not add UI or pressure effects yet. It should first attach a read-only Level 3 reconciliation report to inspection output only at the correct depth/seam, while preserving Level 2 purity and no-enforcement boundaries.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what “Level 3 read-only inspection integration” means and what it does not mean.
- Dependencies and blockers
  - Identify available inspection context, cargo/doc snapshots, depth information, and missing container-class limitations.
- Candidate job sequence
  - Recommend future governed jobs for integration, validation, UI surfacing, and any later pressure-only planning.
- Risk level
  - Classify each candidate job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files and whether `Customs.gd`, `GameState.gd`, or only helper files should be touched.
- Verification strategy
  - Define how future implementation proves report-only behavior, no state mutation, and Level 2 purity.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement, no-pressure-effect, no-UI, and no-Level-2-reconciliation boundaries unless later jobs explicitly change them.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Keep the first integration plan read-only and report-only.
- MUST: Decide whether Level 3 should attach only when resolved inspection depth is at least 3.
- MUST: Identify the narrowest safe integration seam.
- MUST: Keep Level 3 helper ownership separate from Level 2 invariant logic.
- MUST: Preserve Level 2 `policy_disabled_until_level3` behavior.
- MUST: Recommend UI surfacing as a separate later job.
- MUST: Recommend pressure/scrutiny effects, if any, only through a later planning job.
- MUST NOT: implement integration, UI, pressure effects, logs, or enforcement during this planning job.
- MUST NOT: authorize Level 3 behavior from Level 2 paths.
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

Additional sizing guidance for Level 3 integration:
- Integration should be separate from UI surfacing.
- Integration should be separate from pressure/scrutiny effects.
- Integration should be separate from container-class metadata generation unless the planning result proves it is required.
- Any job touching `singletons/GameState.gd` or `singletons/Customs.gd` is high risk by default and should be tightly scoped.
- If context construction can be isolated in `Customs.gd`, prefer avoiding `GameState.gd`.
- If the clean seam requires `GameState.gd`, keep the future implementation job narrow and add explicit no-mutation checks.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0130`, `issue-0131`, `issue-0133`, and `issue-0134` results to preserve helper contract and validation evidence.
- Inspect `GameState.run_customs_inspection`, `Customs.gd`, and existing Level 1/Level 2 audit integration read-only to identify the narrowest safe seam.
- Decide the future report key/name, context construction responsibility, depth gating rule, and missing-data behavior for initial integration.
- Write `results.md` with the recommended implementation job, likely whitelist, risks, verification strategy, and deferred UI/pressure/enforcement boundaries.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/job.md`
- `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/results.md`

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

- `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/job.md`
- `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` defines the recommended Level 3 integration seam and report attachment key.
- [ ] `results.md` states whether Level 3 should be gated by `max_depth >= 3` or another explicit condition.
- [ ] `results.md` defines context construction responsibility and available/missing inputs.
- [ ] `results.md` proposes candidate follow-up jobs with job type, risk level, likely whitelist, narrow goal, and verification approach.
- [ ] `results.md` preserves no-UI, no-pressure-effect, no-enforcement, and Level 2 purity boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/results.md` and confirm it identifies a specific integration seam and report key.
2. Confirm `results.md` defines depth gating and context construction.
3. Confirm `results.md` includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
4. Confirm `results.md` defers UI surfacing, pressure effects, and enforcement to later jobs.
5. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
6. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Integration touches higher-risk inspection flow; do not implement until the seam is explicit.
- The first integration may produce mostly `not_evaluable` container/tare checks until container-class metadata is added.
- If the clean integration seam is ambiguous, recommend a narrower planning or validation job rather than guessing.
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
  - `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/**`
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
  - `git commit -m "issue-0135: Plan Level 3 read-only inspection integration"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/`
2. Write the job text verbatim to `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/job.md`
3. Create `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0135-plan-level-3-read-only-inspection-integration`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0135-plan-level-3-read-only-inspection-integration/results.md`
