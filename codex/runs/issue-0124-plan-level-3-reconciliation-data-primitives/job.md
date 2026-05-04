# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0124
- Short Title: Plan Level 3 reconciliation data primitives
- Run Folder Name: issue-0124-plan-level-3-reconciliation-data-primitives
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Plan the Level 3 reconciliation data primitives needed for future read-only documentary-versus-physical checks. Define the minimum safe data model, milestone boundaries, candidate job sequence, risks, and verification strategy before any runtime implementation begins.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 3 planning must preserve the no-enforcement boundary: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, or forced offloads.
- Level 3 reconciliation must start with data primitives and read-only validation, not punishment or physical inspection gameplay.
- Existing preflight, whitelist, review gate, closeout, canonical workspace, and Epiphanes/Physcon handoff rules remain authoritative.

---

## Non-Goals
Hard scope boundaries.

- Do not implement Level 3 data primitives in this job.
- Do not modify runtime code, scenes, data files, documentation roadmap files, or project settings.
- Do not add cargo reconciliation logic, probable-cause flags, pressure effects, enforcement, UI surfacing, or physical inspection mechanics.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Phase 5 Level 3 reconciliation data primitives
- planning horizon: define the minimum data foundation and job sequence needed before Level 3 read-only reconciliation can exist
- decision type: data-shape planning, safe job decomposition, risk assessment, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
The reconciled inspections/smuggling/customs roadmap marks Phase 5 as the future milestone for Level 3 reconciliation data primitives. Level 2 documentary audit infrastructure is substantially complete and intentionally keeps runtime cargo reconciliation disabled by policy. The next milestone should not jump directly to enforcement or physical inspections; it should first define the data required to support future read-only reconciliation.

Likely primitive categories include commodity mass-per-unit, container tare weights, hull or cargo baseline mass, and tolerance rules. These may touch protected or high-risk areas later, including `data/**`, `singletons/GameState.gd`, and `scripts/customs/**`, so implementation should be planned before any files are changed.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what “Level 3 reconciliation data primitives” means and what it does not mean.
- Dependencies and blockers
  - Identify what existing data/doc/cargo structures must be understood before implementation.
- Candidate job sequence
  - Propose small future governed jobs for data addition, read-only helpers, validation, and eventual UI surfacing.
- Risk level
  - Classify each candidate job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files/directories for each proposed job, while keeping sketches advisory.
- Verification strategy
  - Define how each job proves that data exists or read-only logic works without changing enforcement/gameplay outcomes.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement and no-physical-inspection boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat Level 3 reconciliation as a staged milestone beginning with inert data primitives.
- MUST: Keep the first implementation job limited to data availability or schema support unless this planning job identifies a safer alternative.
- MUST: Separate data definition, read-only reconciliation logic, pressure/consequence behavior, and UI surfacing into distinct candidate jobs unless this planning output justifies coupling.
- MUST: Preserve Level 2 purity: no runtime cargo reconciliation should be added to Level 2 paths.
- MUST: Record uncertainties and blockers instead of guessing data ownership.
- MUST NOT: authorize enforcement, physical inspections, or Port Authority simulation.
- MUST NOT: treat this planning output as executable scope without a future complete `job.md`.
- MUST NOT: recommend broad changes to `GameState`, `Customs`, `data/**`, or document systems without splitting them into smaller jobs.

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

Additional sizing guidance for Level 3:
- Data primitive additions should be separate from reconciliation logic.
- Reconciliation helper logic should be separate from UI surfacing.
- Any pressure/scrutiny effect from reconciliation findings should be a later separate job.
- Anything touching `data/**`, `singletons/GameState.gd`, `singletons/Customs.gd`, or `scripts/customs/**` is medium-to-high risk by default.
- Avoid introducing new saved state unless explicitly required and separately verified.
- Prefer read-only deterministic helpers before player-facing consequences.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read the reconciled roadmap and recent Level 2 purity/audit results to preserve milestone boundaries.
- Inspect existing data, cargo, commodity, document, and customs structures read-only to identify likely data ownership.
- Define the minimum Level 3 data primitive set and the order in which it should be introduced.
- Write `results.md` with candidate jobs, risks, likely whitelists, verification strategy, blockers, and recommendation for the next executable job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/job.md`
- `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md`

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

- `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/job.md`
- `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` defines the minimum Level 3 reconciliation data primitive set and explicit non-goals.
- [ ] `results.md` identifies existing data/cargo/document/customs structures relevant to implementation.
- [ ] `results.md` proposes a candidate job sequence with job type, risk level, likely whitelist, narrow goal, and verification approach for each job.
- [ ] `results.md` recommends the next executable job or explains why another planning/validation job is needed first.
- [ ] `results.md` preserves the no-enforcement, no-physical-inspection, and Level 2 purity boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md` and confirm it defines the Level 3 primitive set and non-goals.
2. Confirm `results.md` includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
3. Confirm `results.md` identifies blockers or uncertainties rather than guessing data ownership.
4. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
5. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Level 3 touches conceptually sensitive systems: data definitions, cargo/document semantics, customs audit logic, and eventual player-facing suspicion.
- If existing data structures do not support safe primitive insertion, recommend a narrower discovery or schema-planning job rather than inventing architecture.
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
  - `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/**`
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
  - `git commit -m "issue-0124: Plan Level 3 reconciliation data primitives"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/`
2. Write the job text verbatim to `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/job.md`
3. Create `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0124-plan-level-3-reconciliation-data-primitives`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md`
