# Planning Job

## Metadata (Required)
- Issue/Task ID: issue-0119
- Short Title: Reconcile inspections smuggling customs roadmap
- Run Folder Name: issue-0119-reconcile-inspections-smuggling-customs-roadmap
- Job Type: planning
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Reconcile the inspections, smuggling, and customs roadmap against the current repository state and recent completed runs. Produce an updated roadmap plus a candidate sequence of safe, governed jobs for the remaining feature work.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Roadmap updates must reflect existing implemented work rather than inventing new implementation.
- Desloppify findings remain advisory and must not drive cleanup work during this job.
- Existing preflight, whitelist, review gate, closeout, canonical workspace, and Epiphanes/Physcon handoff rules remain authoritative.

---

## Non-Goals
Hard scope boundaries.

- Do not implement feature, bugfix, refactor, test, Desloppify, or runtime changes.
- Do not modify `scripts/**`, `singletons/**`, `scenes/**`, `data/**`, `.godot/**`, `.desloppify/**`, or `project.godot`.
- Do not run Desloppify or any external audit tool.
- Do not create executable future job run folders.
- Do not edit unrelated documentation outside the inspections/smuggling/customs roadmap.

---

## Planning Scope
Describe the planning surface this job covers:
- milestone or capability area: inspections, smuggling, customs pressure, document audits, and read-only/pressure-only consequence progression
- planning horizon: reconcile current completed work through `issue-0118`, then plan the next safe feature milestone sequence
- decision type: roadmap reconciliation, milestone boundary clarification, and candidate governed job sequencing

Planning jobs must not authorize runtime implementation by themselves.

---

## Context
The current roadmap document, `Documentation/Roadmap — Inspections, Smuggling, And Customs`, still describes Phase 3 as the next active phase. Recent completed runs show that the codebase has already advanced through substantial Level 1 and Level 2 audit infrastructure and related pressure behavior, including Level 1 audit formalism, Level 2 invariant/audit pipeline work, audit formatting/log visibility, pressure escalation persistence, and deterministic pressure decay.

This creates planning ambiguity: the roadmap no longer cleanly reflects the implemented state, and the next feature work should be selected from an updated capability map rather than from stale phase labels. The project now has a first-class planning job type and safe job sizing policy, so this job should translate the roadmap into governed future jobs without authorizing implementation.

---

## Planning Outputs (Required)
Capture the planning artifacts this job must produce where practical.

- Capability or milestone definition
  - Identify completed, partial, stale, and future milestone capabilities for inspections/smuggling/customs.
- Dependencies and blockers
  - Note runtime/manual verification gaps, design dependencies, and sequencing constraints.
- Candidate job sequence
  - Propose the next set of small governed jobs, each with job type, risk, likely whitelist, narrow goal, and verification approach.
- Risk level
  - Classify candidate jobs as low, medium, or high risk.
- Likely whitelist sketch for future executable jobs
  - Include likely files/directories, but keep sketches advisory.
- Verification strategy
  - Define how each milestone/job could be verified manually or statically.
- Explicit non-goals for each planned phase
  - Preserve “no enforcement” boundaries unless the roadmap explicitly moves to a later milestone.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat this job’s candidate job sequence as advisory planning output only.
- MUST: Update the roadmap to reflect actual completed work through recent run history where evidence is clear.
- MUST: Preserve clear milestone boundaries between read-only detection, pressure-only consequences, reconciliation data, and enforcement.
- MUST: Split future work into small, safe, reviewable jobs using the planning job sizing policy.
- MUST: Record unresolved ambiguity in `results.md` instead of guessing implementation truth.
- MUST NOT: Modify runtime files or implement roadmap items during this job.
- MUST NOT: treat Desloppify findings as higher priority than the reconciled feature roadmap unless the planning output explicitly recommends a future governed job.
- MUST NOT: introduce fines, seizures, holds, cargo denial, travel blocking, reputation effects, or Port Authority simulation as near-term implementation unless the reconciled roadmap clearly authorizes a later milestone.

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

Additional Tiny Cormorant sizing guidance for this roadmap:
- Read-only planning or documentation updates may read broadly but should write only planning/roadmap/run files.
- Runtime feature jobs should usually touch 1-3 files and one player-visible behavior.
- Jobs touching `singletons/GameState.gd`, `singletons/Customs.gd`, `scripts/customs/**`, persistence, inspection depth, or pressure formulas are high-risk by default and should be narrow.
- UI surfacing should be separated from core logic unless the change is trivial and tightly coupled.
- Refactors must be separate from behavior changes unless a future job explicitly explains why they cannot be separated.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Run preflight and confirm the canonical clone is clean and current.
- Read the roadmap document and relevant recent run summaries from inspection/customs-related issues, especially the Level 1, Level 2, pressure, governance, and Desloppify evaluation runs.
- Reconcile roadmap phases against implemented state, marking completed, partial, stale, deferred, and next candidate capabilities.
- Update the roadmap document to reflect the reconciled phase/capability map without adding implementation.
- Write `results.md` with a candidate future job sequence, safe sizing notes, risks, dependencies, and recommendation on whether to continue feature work or schedule a targeted Desloppify-informed job.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `Documentation/Roadmap — Inspections, Smuggling, And Customs`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/job.md`
- `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files or directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**`
- `.godot/**`
- `.desloppify/**`
- `project.godot`
- `Documentation/Freight Documentation Inspection Model.md`
- `Documentation/LOGGING.md`
- `Documentation/Smuggling How-To.md`
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

- `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/job.md`
- `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] The roadmap document reflects current completed/partial/future state using recent run history as evidence.
- [ ] `results.md` lists a candidate future job sequence with job type, risk level, likely whitelist, narrow goal, and verification approach for each proposed job.
- [ ] `results.md` identifies dependencies, blockers, manual verification gaps, and unresolved ambiguities.
- [ ] The roadmap preserves clear deferred boundaries for enforcement, physical inspections, and Port Authority simulation.
- [ ] No runtime files, project settings, unrelated documentation, external audit state, or non-whitelisted governance files are modified.

---

## Verification Steps (Non-Game)
How a human verifies the planning change by reading files and or running git commands.

1. Read `Documentation/Roadmap — Inspections, Smuggling, And Customs` and confirm it reconciles the roadmap against recent completed inspection/customs work.
2. Read `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/results.md` and confirm it includes candidate jobs with risk, likely whitelist, narrow goal, and verification approach.
3. Run `git diff --stat` and full `git diff` and confirm only the whitelisted roadmap/run files changed.
4. Confirm no files under `scripts/**`, `singletons/**`, `scenes/**`, `data/**`, `.godot/**`, `.desloppify/**`, `project.godot`, or non-whitelisted documentation/governance paths changed.
5. Confirm future jobs are described as advisory candidates, not executable authorization.

---

## Risks / Notes
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- If the roadmap and code history disagree, prefer documenting the disagreement and recommending a validation job rather than guessing.
- If recent run summaries are insufficient to determine actual runtime state, mark the capability as partial or requiring validation.
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
  - `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/**`
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
  - `git commit -m "issue-0119: Reconcile inspections smuggling customs roadmap"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/`
2. Write the job text verbatim to `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/job.md`
3. Create `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `issue-0119-reconcile-inspections-smuggling-customs-roadmap`

Codex must not create a run folder from an incomplete job description, an informal recommendation, or a non-executable planning note.

Codex must write final results only to:
- `codex/runs/issue-0119-reconcile-inspections-smuggling-customs-roadmap/results.md`
