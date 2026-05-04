# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0125
- Short Title: Audit existing commodity weight semantics
- Run Folder Name: issue-0125-audit-existing-commodity-weight-semantics
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Determine whether the existing `CommodityDB.COMMODITIES[*].weight_per_unit` field can serve as the Level 3 customs mass source of truth, or whether future Level 3 work needs a separate customs-specific mass primitive. Produce a field-ownership recommendation before any `data/**` implementation begins.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- `data/**` must remain unmodified in this planning job.
- Level 3 reconciliation must preserve the no-enforcement boundary: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, or forced offloads.
- Level 2 quantity/cargo reconciliation must remain policy-disabled until a future Level 3 executable job explicitly introduces a Level 3-only path.

---

## Non-Goals
Hard scope boundaries.

- Do not edit `data/CommodityDB.gd` or any other data file.
- Do not add Level 3 primitives, helpers, reconciliation logic, UI surfacing, pressure effects, or enforcement.
- Do not modify runtime code, scenes, data files, documentation roadmap files, project settings, or governance files.
- Do not run Desloppify or external audit tooling.
- Do not create executable future job run folders.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: Phase 5 Level 3 commodity mass semantics
- planning horizon: decide whether existing commodity weight data is sufficient before adding inert Level 3 primitives
- decision type: read-only field ownership audit, dependency mapping, and next-job recommendation

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
`issue-0124` identified `CommodityDB.COMMODITIES[*].weight_per_unit` as the closest existing primitive for commodity mass, but its semantics are not formally owned by customs. It may currently represent cargo capacity weight, gameplay trade weight, physical mass, or a simplified blend. Level 3 reconciliation needs a deterministic source of truth for commodity mass, but using the existing field without confirming meaning could make customs reconciliation ambiguous or brittle.

Before touching protected `data/**`, the project needs a read-only audit of where `weight_per_unit` is defined, how it is used, whether units are implied, and whether it can safely become the customs mass source of truth.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Define what commodity mass means for future Level 3 reconciliation.
- Dependencies and blockers
  - Identify existing code paths that use `weight_per_unit`, cargo capacity, document cargo lines, or commodity quantities.
- Candidate job sequence
  - Recommend the next governed job based on whether existing `weight_per_unit` is sufficient.
- Risk level
  - Classify the recommended next job and alternatives as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files for either reusing `weight_per_unit` or adding a separate customs mass primitive.
- Verification strategy
  - Define how a future executable job proves completeness and no side effects.
- Explicit non-goals for each planned phase
  - Preserve no-enforcement, no-physical-inspection, and no-Level-2-reconciliation boundaries.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Audit existing `weight_per_unit` definition and usage read-only before recommending data changes.
- MUST: Decide whether `weight_per_unit` should be treated as customs mass, cargo-space weight, or insufficient/ambiguous.
- MUST: Record evidence from source locations rather than relying on naming alone.
- MUST: Recommend a next job that is narrow enough to review safely.
- MUST: Preserve Level 2 purity and no-enforcement boundaries.
- MUST NOT: edit `data/**` or runtime code during this planning job.
- MUST NOT: invent units, tolerances, or mass semantics without evidence or an explicit recommendation.
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

Additional sizing guidance for commodity mass work:
- A data semantics decision should precede any `data/**` edit.
- Adding or renaming commodity fields should be separate from reconciliation logic.
- Tolerance policy should be separate from commodity mass unless the audit shows they are inseparable.
- Anything touching `data/**`, `singletons/GameState.gd`, `singletons/Customs.gd`, or `scripts/customs/**` is medium-to-high risk by default.
- If existing `weight_per_unit` is sufficient, the next executable job should prefer inert validation/accessor support over immediate audit integration.
- If existing `weight_per_unit` is ambiguous, the next executable job should add a separate inert customs mass primitive with static verification only.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read `issue-0124` results and relevant roadmap context to preserve Level 3 boundaries.
- Inspect `data/CommodityDB.gd` and read-only usage sites for `weight_per_unit`, cargo capacity, cargo quantities, and freight document cargo lines.
- Map whether existing weight semantics are used for cargo-space constraints, economy, documents, customs, or only display/data.
- Write `results.md` with a field-ownership recommendation, evidence, risks, and the next safe governed job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/job.md`
- `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/results.md`

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

- `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/job.md`
- `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] `results.md` identifies where `weight_per_unit` is defined and where it is used.
- [ ] `results.md` states whether `weight_per_unit` is sufficient as Level 3 customs mass, ambiguous, or insufficient.
- [ ] `results.md` records evidence for the recommendation and any unresolved uncertainty.
- [ ] `results.md` recommends the next safe governed job with job type, risk level, likely whitelist, narrow goal, and verification approach.
- [ ] `results.md` preserves no-enforcement and Level 2 purity boundaries.
- [ ] No files outside the active run folder and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/results.md` and confirm it maps `weight_per_unit` definition and usage.
2. Confirm `results.md` makes a clear field-ownership recommendation with evidence.
3. Confirm `results.md` proposes a narrow next governed job and preserves no-enforcement/Level-2-purity boundaries.
4. Run `git diff --stat` and full `git diff` and confirm only the active run files and `codex/runs/ACTIVE_RUN.txt` changed.
5. Confirm no files under `data/**`, `scripts/**`, `singletons/**`, `scenes/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- This job may reveal that the field name is too generic for customs use; record that as a recommendation rather than changing data.
- If usage cannot be determined from source inspection, recommend a narrower validation or documentation job before data implementation.
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
- If Codex detects a non-canonical Tiny Cormant clone, it must warn and stop until the human confirms that alternate path.
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
  - `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/**`
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
  - `git commit -m "issue-0125: Audit existing commodity weight semantics"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/`
2. Write the job text verbatim to `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/job.md`
3. Create `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0125-audit-existing-commodity-weight-semantics`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0125-audit-existing-commodity-weight-semantics/results.md`
