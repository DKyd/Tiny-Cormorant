# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0127
- Short Title: Plan Level 3 container tare and tolerance primitives
- Run Folder Name: issue-0127-plan-level-3-container-tare-and-tolerance-primitives
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Plan the remaining inert Level 3 data primitives needed before read-only reconciliation helpers can exist: container tare/class data and reconciliation tolerance policy. Decide data ownership, minimum schema, candidate job sequence, risks, and verification strategy without modifying runtime or data files.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- `data/**` must remain unmodified in this planning job.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- Level 3 reconciliation must preserve the no-enforcement boundary: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.
- Existing `customs_mass_per_unit` data from `issue-0126` remains inert and unwired.

---

## Non-Goals
Hard scope boundaries.

- Do not edit `data/**`, runtime code, scenes, documentation roadmap files, project settings, or governance files.
- Do not add container tare data, tolerance data, helpers, validators, reconciliation logic, UI surfacing, pressure effects, or enforcement.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.
- Do not investigate the Godot signal 11 beyond noting whether it affects planning assumptions.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Phase 5 Level 3 container tare/class and tolerance primitives
- planning horizon: decide the minimum inert data shape needed before read-only reconciliation helpers
- decision type: read-only data ownership planning, schema sketching, risk assessment, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
`issue-0124` identified the minimum Level 3 primitive set: commodity customs mass, cargo/document quantity shapes, container metadata baseline, ship/hull/cargo baseline capacity, and tolerance rules. `issue-0125` concluded that existing `weight_per_unit` is ambiguous for customs mass. `issue-0126` added an inert customs-owned `customs_mass_per_unit` field to all commodities and confirmed no runtime path reads it.

The remaining primitive gap before read-only reconciliation helpers is container tare/class data plus deterministic tolerance policy. Existing `container_meta` includes identity/provenance fields such as `container_id`, `seal_id`, `seal_state`, and `packed_tick`, but no tare weight or container class source of truth was identified. No tolerance or rounding policy was identified.

This job should decide where those primitives should live and how they should be split into safe future jobs.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what container tare/class and tolerance primitives mean for Level 3.
- Dependencies and blockers
  - Identify existing container metadata, document cargo-line, cargo capacity, and customs audit structures relevant to future implementation.
- Candidate job sequence
  - Recommend future governed jobs for inert data, validation/accessors, and later read-only reconciliation helpers.
- Risk level
  - Classify each candidate job as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files/directories and whether a new data file should be allowed.
- Verification strategy
  - Define how each future job proves data completeness, deterministic lookup, and absence of gameplay side effects.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement, no-physical-inspection, and no-Level-2-reconciliation boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Plan container tare/class and tolerance primitives as inert data first.
- MUST: Decide whether primitives belong in `data/CommodityDB.gd`, a new dedicated data file, or a future helper module before implementation.
- MUST: Preserve separation between data definition, read-only lookup/validation, reconciliation logic, pressure effects, and UI surfacing.
- MUST: Define missing-data behavior and tolerance semantics as part of the future job sequence.
- MUST: Record uncertainty rather than spreading constants across unrelated runtime files.
- MUST NOT: modify `data/**` or runtime code during this planning job.
- MUST NOT: wire `customs_mass_per_unit` into reconciliation or audit behavior during this planning job.
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

Additional sizing guidance for container/tolerance work:
- Container tare/class data should be separate from reconciliation helper logic.
- Tolerance policy should be separate from pressure/consequence behavior.
- If a new data file is recommended, that file path must be explicitly listed in the future job’s “New Files Allowed” section.
- Anything touching `data/**`, `scripts/customs/**`, `singletons/Customs.gd`, or `singletons/GameState.gd` is medium-to-high risk by default.
- Missing-data behavior should be decided before helper implementation.
- UI surfacing should happen only after read-only helper outputs exist and are verified.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0124`, `issue-0125`, and `issue-0126` results to preserve Level 3 primitive boundaries.
- Inspect existing container metadata, freight document rules, cargo capacity, customs audit, and commodity data read-only.
- Decide whether container/tolerance primitives should be centralized in an existing data file or a new dedicated data surface.
- Write `results.md` with recommended schema, candidate jobs, risks, likely whitelists, verification strategy, and next executable job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/job.md`
- `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/results.md`

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

- `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/job.md`
- `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` defines recommended container tare/class and tolerance primitive semantics.
- [ ] `results.md` recommends data ownership location, including whether a new data file should be created in a future job.
- [ ] `results.md` defines missing-data behavior and deterministic tolerance policy expectations at planning level.
- [ ] `results.md` proposes a candidate job sequence with job type, risk level, likely whitelist, narrow goal, and verification approach for each job.
- [ ] `results.md` recommends the next executable job or explains why another planning/validation job is needed first.
- [ ] `results.md` preserves no-enforcement, no-physical-inspection, no-Level-2-reconciliation, and inert-customs-mass boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/results.md` and confirm it defines container tare/class and tolerance primitive recommendations.
2. Confirm `results.md` recommends where data should live and whether a new file is needed.
3. Confirm `results.md` includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
4. Confirm `results.md` preserves no-enforcement and Level 2 purity boundaries.
5. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
6. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- `issue-0126` reported a Godot headless engine signal 11 during smoke verification; this job should not chase it unless it affects data-planning conclusions.
- Container tare/class and tolerance policy may need a new data surface; if so, recommend exact future paths and keep implementation separate.
- If existing metadata is too thin to infer safe ownership, recommend a narrower schema-only job rather than inventing runtime architecture.
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
  - `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/**`
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
  - `git commit -m "issue-0127: Plan Level 3 container tare and tolerance primitives"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/`
2. Write the job text verbatim to `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/job.md`
3. Create `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0127-plan-level-3-container-tare-and-tolerance-primitives`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0127-plan-level-3-container-tare-and-tolerance-primitives/results.md`
