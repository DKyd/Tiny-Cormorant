```markdown
# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0130
- Short Title: Plan Level 3 read-only reconciliation helper
- Run Folder Name: issue-0130-plan-level-3-read-only-reconciliation-helper
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Plan the first Level 3 read-only reconciliation helper before implementation. Define helper ownership, input context, output payload shape, statuses, missing-data behavior, deterministic comparison rules, verification strategy, and candidate follow-up jobs without modifying runtime or data files.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- Level 3 reconciliation must remain read-only until a future executable job explicitly changes behavior.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.
- Existing Level 3 data primitives and accessors from `issue-0126`, `issue-0128`, and `issue-0129` must remain inert and unwired during this planning job.

---

## Non-Goals
Hard scope boundaries.

- Do not implement the Level 3 reconciliation helper in this job.
- Do not modify `data/**`, runtime code, scenes, documentation roadmap files, project settings, or governance files.
- Do not add UI surfacing, pressure effects, inspection triggers, audit integration, scenario harnesses, or enforcement.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Phase 6 Level 3 read-only reconciliation helper
- planning horizon: define the first helper implementation boundary after inert data/accessor groundwork
- decision type: helper ownership, context/output schema, comparison semantics, risk assessment, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
Level 3 primitive groundwork now exists but remains inert. `issue-0126` added `customs_mass_per_unit` to commodity data. `issue-0128` added `data/CustomsReconciliationDB.gd` with container class/tare data and tolerance policies. `issue-0129` added read-only primitive accessors and confirmed no runtime systems call them.

The next milestone step is a read-only reconciliation helper that can compare documentary declarations against runtime/physical facts in a deterministic report-only way. This is behavior-adjacent and may involve `scripts/customs/**`, `singletons/Customs.gd`, `singletons/GameState.gd`, and data accessors in future jobs. Before implementation, the project needs a precise helper contract and safe job boundary.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what the first Level 3 read-only reconciliation helper should and should not do.
- Dependencies and blockers
  - Identify required source data: declared cargo lines, runtime cargo snapshot, customs mass per unit, container class/tare data, tolerance policy, and missing-data behavior.
- Candidate job sequence
  - Recommend future governed jobs for helper implementation, validation/harness support, integration, UI surfacing, and any later pressure-only behavior.
- Risk level
  - Classify each candidate job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files/directories and whether a new helper file should be allowed.
- Verification strategy
  - Define how a future helper proves deterministic report-only behavior and absence of side effects.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement, no-physical-inspection, no-Level-2-reconciliation, and no-pressure-effect boundaries unless a later job explicitly changes them.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Keep the first Level 3 reconciliation helper read-only and deterministic.
- MUST: Define a stable input context and output payload shape before implementation.
- MUST: Keep Level 3 helper behavior separate from Level 2 invariant policy.
- MUST: Define missing-data behavior as explicit `not_evaluable` or equivalent report output, not as implicit failure.
- MUST: Separate helper implementation from UI surfacing, pressure effects, and enforcement.
- MUST: Record whether a scenario harness is required before or after helper implementation.
- MUST NOT: modify runtime code, data files, scenes, project settings, or governance files in this planning job.
- MUST NOT: wire Level 3 helper output into inspections, pressure, UI, logs, or gameplay during this planning job.
- MUST NOT: authorize enforcement, physical inspections, or Port Authority simulation.
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

Additional sizing guidance for Level 3 helper work:
- Helper implementation should be separate from inspection integration.
- Inspection integration should be separate from UI surfacing.
- Pressure-only consequences from Level 3 findings must be planned separately before implementation.
- Any helper touching `scripts/customs/**`, `singletons/Customs.gd`, or `singletons/GameState.gd` is medium-to-high risk by default.
- If deterministic validation requires test/scenario support, consider a separate harness/planning job before wiring helper output into live inspections.
- Avoid broad rewrites of existing Level 1/Level 2 audit code.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0124` through `issue-0129` results to preserve Level 3 primitive and accessor boundaries.
- Inspect existing customs audit helpers, freight document cargo-line shapes, GameState cargo snapshot shape, and data accessor APIs read-only.
- Define the proposed Level 3 helper contract: owner file, input context, output fields, statuses, ordering, missing-data behavior, and side-effect boundaries.
- Write `results.md` with candidate jobs, risks, likely whitelists, verification strategy, and recommendation for the next executable job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/job.md`
- `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/results.md`

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

- `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/job.md`
- `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` defines the proposed Level 3 helper owner/location and whether a new helper file is recommended.
- [ ] `results.md` defines proposed input context and output payload shape.
- [ ] `results.md` defines statuses, missing-data behavior, deterministic ordering, and tolerance semantics.
- [ ] `results.md` identifies dependencies and blockers, including whether a scenario harness is needed.
- [ ] `results.md` proposes candidate follow-up jobs with job type, risk level, likely whitelist, narrow goal, and verification approach.
- [ ] `results.md` preserves no-enforcement, no-physical-inspection, no-Level-2-reconciliation, and no-pressure-effect boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/results.md` and confirm it defines helper ownership, input context, output payload, statuses, and missing-data behavior.
2. Confirm `results.md` includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
3. Confirm `results.md` states whether a scenario harness is required before implementation or integration.
4. Confirm `results.md` preserves no-enforcement, no-physical-inspection, no-Level-2-reconciliation, and no-pressure-effect boundaries.
5. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
6. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- This is the first behavior-adjacent Level 3 step; implementation should not begin until helper boundaries are clear.
- Existing runtime validation still lacks a deterministic non-interactive customs scenario harness; record whether that blocks helper implementation or only later integration.
- If helper ownership is ambiguous, recommend a narrow follow-up planning job rather than guessing architecture.
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
  - `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/**`
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
  - `git commit -m "issue-0130: Plan Level 3 read-only reconciliation helper"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/`
2. Write the job text verbatim to `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/job.md`
3. Create `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0130-plan-level-3-read-only-reconciliation-helper`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0130-plan-level-3-read-only-reconciliation-helper/results.md`
```
