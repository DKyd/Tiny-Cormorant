# Governance Job

## Metadata (Required)
- Issue/Task ID: issue-0118
- Short Title: Add planning job type and safe job sizing policy
- Run Folder Name: issue-0118-add-planning-job-type-and-safe-job-sizing-policy
- Job Type: governance
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Add a first-class planning job type for roadmap, milestone, and job-sequencing work. Formalize safe job sizing policy so future feature work is planned as reviewable, whitelist-bound jobs rather than broad feature blobs.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- Runtime game behavior must not change.
- Planning jobs must not authorize runtime implementation by themselves.
- Planning outputs must become executable only when converted into complete future `job.md` templates or active job instructions.
- Existing preflight, whitelist, review gate, closeout, canonical workspace, and Epiphanes/Physcon handoff rules remain authoritative.
- Desloppify and other external audit findings remain advisory unless converted into governed jobs.

---

## Non-Goals
Hard scope boundaries.

- Do not update the inspections/smuggling roadmap content in this job.
- Do not run Desloppify or any external audit tool.
- Do not implement feature, bugfix, refactor, test, or runtime changes.
- Do not modify `scripts/**`, `singletons/**`, `scenes/**`, `data/**`, `Documentation/**`, `.godot/**`, `.desloppify/**`, or `project.godot`.
- Do not create actual roadmap candidate jobs beyond this run folder.

---

## Context
Tiny Cormorant’s governance now distinguishes the human, Epiphanes, and Physcon roles, and requires complete job templates for executable work. The next process gap is roadmap planning itself: existing job types cover feature, bugfix, refactor, and governance, but there is no first-class job type for non-runtime planning work such as milestone decomposition, roadmap reconciliation, sequencing candidate jobs, or evaluating safe implementation boundaries.

The inspections/smuggling/customs roadmap also needs reconciliation against recent completed runs. Before doing that content work, the project needs a planning template and safe job sizing policy so roadmap work produces governed job sequences rather than vague implementation scope.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Use planning jobs for roadmap reconciliation, milestone decomposition, job sequencing, release/milestone capability planning, and non-executable implementation scoping.
- MUST: Treat planning job outputs as advisory until converted into complete executable job templates or explicitly authorized active-run instructions.
- MUST: Define each roadmap item as a capability, dependency, risk level, candidate job sequence, and verification strategy where practical.
- MUST: Split planned work when it crosses job type boundaries, changes multiple independent behaviors, mixes refactor with feature implementation, or exceeds safe job size limits.
- MUST: Mark runtime implementation as out of scope for planning jobs.
- MUST: Include safe job sizing guidance in planning rules or template.
- MUST: Keep Desloppify/external audit findings subordinate to roadmap and job governance.
- MUST NOT: Use planning jobs to modify runtime code.
- MUST NOT: treat roadmap entries, planning notes, or candidate job lists as executable scope by themselves.
- MUST NOT: combine unrelated milestones into one implementation job for convenience.

---

## Proposed Approach
High-level plan (3–6 bullets). Boundaries only.

- Add a new `codex/jobs/planning/` job type with `template.md`, `rules.md`, and `config.md`.
- Update governance docs to recognize `planning/` as a valid job type.
- Encode safe job sizing guidance in the planning job rules/template.
- Define required planning outputs such as milestone map, candidate job list, dependencies, risk, whitelist sketch, and non-goals.
- Keep implementation strictly limited to governance/job-system files and this run folder.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/AGENTS.md`
- `codex/README.md`
- `codex/jobs/planning/template.md`
- `codex/jobs/planning/rules.md`
- `codex/jobs/planning/config.md`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/job.md`
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**`
- `.godot/**`
- `.desloppify/**`
- `Documentation/**`
- `project.godot`
- `codex/CONTEXT.md`
- `codex/jobs/feature/**`
- `codex/jobs/bugfix/**`
- `codex/jobs/refactor/**`
- `codex/jobs/governance/**`
- `codex/tools/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/jobs/planning/template.md`
- `codex/jobs/planning/rules.md`
- `codex/jobs/planning/config.md`
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/job.md`
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable “done.”

- [ ] `codex/jobs/planning/template.md`, `rules.md`, and `config.md` exist and define a non-runtime planning job type.
- [ ] Planning rules state that planning outputs are advisory until converted into complete future job templates or explicit active-run instructions.
- [ ] Planning rules/template include safe job sizing guidance and split criteria.
- [ ] `codex/AGENTS.md` and `codex/README.md` recognize `planning/` as a valid job type.
- [ ] Planning template includes fields for milestone capability, dependencies, candidate job sequence, risk level, likely whitelist, verification strategy, and non-goals.
- [ ] No runtime files, roadmap documentation, external audit state, or non-whitelisted governance files are modified.

---

## Verification Steps (Non-Game)
How a human verifies the governance change (reading files and/or git commands).

1. Read `codex/jobs/planning/template.md` and confirm it supports roadmap/milestone/job-sequencing work without authorizing runtime changes.
2. Read `codex/jobs/planning/rules.md` and confirm safe job sizing and split criteria are explicit.
3. Read `codex/AGENTS.md` and `codex/README.md` and confirm `planning/` is listed as a valid job type.
4. Run `git diff --stat` and full `git diff` and confirm only whitelisted files changed.
5. Confirm no files under `data/**`, `scenes/**`, `scripts/**`, `singletons/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- If planning job language overlaps with governance job language, keep planning focused on roadmap/job sequencing and governance focused on process/policy changes.
- If safe job sizing limits conflict with existing governance rules, preserve stricter existing gates and document planning guidance as defaults.
- If future roadmap reconciliation needs to edit `Documentation/**`, that must happen in a separate planning job whose whitelist explicitly permits it.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- Gate B approvals must include scope proof (`git status`, `git diff --stat`, full `git diff`).
- If scope/whitelist/non-goals are violated, Codex must stop and report the issue.

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage → staged diff review → commit → push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately.
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, this run folder, or job whitelist.
  - Runtime files or roadmap docs are modified.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0118: Add planning job type and safe job sizing policy"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes:

1) Create `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/`
2) Write this job verbatim to `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/job.md`
3) Create `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0118-add-planning-job-type-and-safe-job-sizing-policy`

Codex must write final results only to:
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/results.md`
