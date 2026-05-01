# Governance Job

## Metadata (Required)
- Issue/Task ID: issue-0115
- Short Title: Formalize canonical desktop clone workflow
- Run Folder Name: issue-0115-formalize-canonical-desktop-clone-workflow
- Job Type: governance
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Formalize the canonical local workspace workflow for Tiny Cormorant so VSCode Codex, Desktop Codex, Godot, and human tooling operate from the same authoritative clone unless explicitly directed otherwise. Strengthen preflight/sync rules and remove ambiguity around scratch clones, run-folder creation authority, and git gate failure behavior.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- Governance changes must not modify gameplay logic, scenes, data, UI behavior, or runtime systems.
- Codex must still operate only within the active job whitelist.
- Every job must remain auditable through preflight, staged diff review, closeout proof, and `results.md`.

---

## Non-Goals
Hard scope boundaries.

- Do not change any runtime game files, including `scripts/**`, `singletons/**`, `scenes/**`, or `data/**`.
- Do not implement gameplay, UI, economy, customs, inspection, save/load, or logging behavior.
- Do not rename existing run folders or rewrite historical job results.
- Do not change git remotes, branches, credentials, or repository history.

---

## Context
The canonical local Tiny Cormorant clone is:

`C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`

This clone should be shared by VSCode, Godot, Desktop Codex, and human review workflows whenever possible. An older scratch clone under `Documents/Codex` is non-canonical and should not silently become the working source of truth.

Recent governance has also accumulated some ambiguity:
- Some docs say only the human may create run folders.
- Other docs allow Codex bootstrap creation when the human provides a complete job template.
- Some references mention `config.json`, while current job configs are `config.md`.
- `codex/tools/git_gates.ps1` prints useful preflight/postflight information but does not currently fail hard on dirty trees, staged changes, untracked files, or branch-behind conditions.

This creates risk that different Codex surfaces could work from different clones, skip sync expectations, or continue after gate violations that should stop the job.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` as the canonical local workspace for Tiny Cormorant unless the human explicitly names another path for a specific task.
- MUST: Run the preflight gate before any job implementation or governance edit.
- MUST: Stop before implementation if the working tree is dirty, contains staged changes, contains untracked files, or is behind origin.
- MUST: Warn and stop if Codex detects it is operating from a non-canonical Tiny Cormorant clone, unless the human explicitly confirms that clone for the current job.
- MUST: Keep run-folder creation authority consistent across `codex/AGENTS.md`, `codex/README.md`, and governance templates.
- MUST: Make gate violations auditable and machine-detectable where practical, including nonzero script exit codes for hard preflight/postflight failures.
- MUST NOT: Use the older `Documents/Codex` scratch clone as the default Tiny Cormorant working copy.
- MUST NOT: Continue a job after a git gate violation unless the human explicitly resolves the stop condition.
- MUST NOT: Create, modify, or rely on undocumented clone-selection behavior.

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

- Update governance docs to define the canonical workspace path and non-canonical clone behavior.
- Reconcile run-folder bootstrap authority so all governance files describe the same rule.
- Correct stale job config references from `config.json` to `config.md` where applicable.
- Strengthen `codex/tools/git_gates.ps1` so hard gate violations fail with clear nonzero exits.
- Pin durable project-orientation facts in `codex/CONTEXT.md`, including Godot 4.6 and canonical high-level structure.
- Keep all changes limited to governance surfaces and the active run folder.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `codex/AGENTS.md`
- `codex/README.md`
- `codex/CONTEXT.md`
- `codex/jobs/governance/template.md`
- `codex/jobs/governance/rules.md`
- `codex/tools/git_gates.ps1`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/job.md`
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**`
- `.godot/**`
- `project.godot`
- `Documentation/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/job.md`
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ] Governance docs clearly identify the canonical local clone path and required behavior for non-canonical/scratch clones.
- [ ] `codex/AGENTS.md`, `codex/README.md`, and `codex/jobs/governance/template.md` no longer conflict about run-folder creation authority.
- [ ] Stale references to `config.json` are corrected to match the repository's current `config.md` files.
- [ ] `codex/tools/git_gates.ps1 -Mode Preflight` fails hard with a nonzero exit when dirty, staged, untracked, or branch-behind conditions are detected.
- [ ] `codex/CONTEXT.md` pins Godot 4.6 and includes durable project-orientation facts relevant to future Codex onboarding.
- [ ] No runtime files, scene files, data files, `.godot/**`, or documentation files outside the whitelist are modified.

---

## Verification Steps (Non-Game)
How a human verifies the governance change (reading files and/or git commands).

1. Run `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight` from the canonical clone and confirm it reports branch/status/sync state clearly.
2. Read `codex/AGENTS.md`, `codex/README.md`, and `codex/jobs/governance/template.md` and confirm clone policy plus run-folder authority are consistent.
3. Run `git diff --stat` and full `git diff` and confirm only whitelisted governance/run files changed.
4. Confirm no files under `data/**`, `scenes/**`, `scripts/**`, `singletons/**`, `.godot/**`, `project.godot`, or `Documentation/**` changed.
5. Confirm `codex/CONTEXT.md` states Godot 4.6 and durable orientation facts without introducing gameplay policy changes.

---

## Risks / Notes
- If existing governance intentionally distinguishes Desktop Codex from VSCode Codex, Codex must stop and report the conflict rather than inventing separate policies.
- If making `git_gates.ps1` fail hard would break an existing closeout workflow, Codex must preserve readable output and document the revised stop behavior clearly.
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
  B) Run the current issue's Closeout Gate (stage -> staged diff review -> commit -> push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0115: Formalize canonical desktop clone workflow"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes:

1) Create `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/`
2) Write this job verbatim to `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/job.md`
3) Create `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0115-formalize-canonical-desktop-clone-workflow`

Codex must write final results only to:
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/results.md`
