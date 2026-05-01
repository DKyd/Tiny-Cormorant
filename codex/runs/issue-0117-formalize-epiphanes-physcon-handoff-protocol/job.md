# Governance Job

## Metadata (Required)
- Issue/Task ID: issue-0117
- Short Title: Formalize Epiphanes Physcon handoff protocol
- Run Folder Name: issue-0117-formalize-epiphanes-physcon-handoff-protocol
- Job Type: governance
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Formalize the collaboration and handoff protocol between the human, Epiphanes, and Physcon so planning discussions, executable jobs, and implementation authority are clearly distinguished. Ensure future work persists through complete job templates rather than ambiguous conversational prompts.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- The human remains the final authority for priorities, job approval, and scope decisions.
- Physcon must execute only from the canonical Tiny Cormorant clone unless explicitly authorized otherwise.
- Runtime game behavior must not change.
- Codex job whitelist, preflight, review gate, and closeout rules remain authoritative.
- A recommendation, roadmap note, or casual instruction must not become executable scope unless converted into a complete job template or an already-active job explicitly permits it.

---

## Non-Goals
Hard scope boundaries.

- Do not create the planning job type in this job.
- Do not update the inspections/smuggling roadmap in this job.
- Do not run Desloppify or any external audit tool in this job.
- Do not modify runtime files, scenes, scripts, singletons, data, or project settings.
- Do not create or execute future feature/refactor/bugfix jobs.

---

## Context
Tiny Cormorant now uses multiple collaboration surfaces. Desktop Codex is being referred to as Epiphanes and is used for planning, orientation, job drafting, and roadmap thinking. VSCode Codex is being referred to as Physcon and is used for canonical-clone execution, preflight, file edits, staging, commit, and push.

The current governance system requires complete job templates, explicit whitelists, and review gates. However, the handoff layer between planning discussion and executable work is still informal. This creates risk that a conversational recommendation such as “start the next roadmap job” could be mistaken for executable authorization.

This job makes the role boundaries and handoff artifact requirements durable in governance.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat the human as final authority for priority, approval, and scope.
- MUST: Treat Epiphanes as the planning/orientation Codex unless the human explicitly assigns it implementation authority for a specific job.
- MUST: Treat Physcon as the execution Codex for canonical-clone work unless the human explicitly assigns execution elsewhere.
- MUST: Distinguish discussion/recommendation from executable job authorization.
- MUST: Provide a complete filled `job.md` template before Physcon starts a new job, unless an active run already exists and the human explicitly instructs Physcon to continue it.
- MUST: Label non-executable planning notes, roadmap recommendations, or draft scopes as non-executable when they are not intended to authorize work.
- MUST: Stop and ask if a handoff prompt is ambiguous, lacks a complete job template, or appears to mix planning advice with implementation instructions.
- MUST: Keep Physcon’s scaffolding authority limited to complete pasted job templates and active job rules.
- MUST NOT: Treat Epiphanes recommendations, roadmap notes, or informal chat summaries as job authorization by themselves.
- MUST NOT: let Physcon create a run folder from an incomplete job description.
- MUST NOT: modify files outside the active job whitelist based on cross-Codex conversational context.

---

## Proposed Approach
High-level plan (3–6 bullets). Boundaries only.

- Add a durable role/handoff section to governance docs defining human, Epiphanes, and Physcon responsibilities.
- Clarify that executable handoffs require a complete filled `job.md` unless continuing an already-active run.
- Add stop conditions for ambiguous prompts, partial job descriptions, and mixed planning/implementation instructions.
- Align bootstrap/run-folder language with the handoff protocol.
- Keep all changes limited to governance files and this run folder.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/AGENTS.md`
- `codex/README.md`
- `codex/jobs/governance/template.md`
- `codex/jobs/governance/rules.md`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/job.md`
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/results.md`

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
- `codex/tools/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/job.md`
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable “done.”

- [ ] Governance docs define the human, Epiphanes, and Physcon roles.
- [ ] Governance docs state that Physcon may start a new job only from a complete filled `job.md`, unless explicitly continuing an active run.
- [ ] Governance docs distinguish non-executable planning/recommendations from executable job authorization.
- [ ] Governance docs include a stop-and-ask rule for ambiguous handoffs or incomplete job prompts.
- [ ] Bootstrap/run-folder language remains consistent with issue-0115 canonical workflow rules.
- [ ] No runtime files, project settings, external audit state, or documentation roadmap files are modified.

---

## Verification Steps (Non-Game)
How a human verifies the governance change (reading files and/or git commands).

1. Read `codex/AGENTS.md` and confirm it defines human, Epiphanes, and Physcon roles plus handoff stop conditions.
2. Read `codex/README.md` and confirm the high-level workflow requires complete job templates for new Physcon jobs.
3. Read `codex/jobs/governance/template.md` and `codex/jobs/governance/rules.md` and confirm governance jobs preserve the handoff protocol.
4. Run `git diff --stat` and full `git diff` and confirm only whitelisted governance/run files changed.
5. Confirm no files under `data/**`, `scenes/**`, `scripts/**`, `singletons/**`, `.godot/**`, `.desloppify/**`, `Documentation/**`, or `project.godot` changed.

---

## Risks / Notes
- If existing governance language conflicts with this protocol, Codex must reconcile it within the whitelist rather than adding a competing rule.
- If the names Epiphanes or Physcon need to change later, they should be updated in one governance job rather than handled informally.
- This job intentionally does not create the future planning job type; that should be a separate job after the handoff protocol is durable.
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
  - `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/**`
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
  - Runtime files are modified.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0117: Formalize Epiphanes Physcon handoff protocol"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes:

1) Create `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/`
2) Write this job verbatim to `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/job.md`
3) Create `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0117-formalize-epiphanes-physcon-handoff-protocol`

Codex must write final results only to:
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/results.md`
