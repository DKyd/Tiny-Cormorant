# Codex Job System - Tiny Cormorant

This directory defines how Codex is used to make controlled, reviewable changes to the Tiny Cormorant codebase.

Codex is not allowed to make free-form changes to the repository.
All work must be performed through a job created from a predefined job type.

`codex/` is governance and is read-only to Codex except for the active run folder, `codex/runs/ACTIVE_RUN.txt`, and any governance files explicitly whitelisted by the active job.

---

## Canonical Workspace
- The canonical local Tiny Cormorant clone is `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`.
- VSCode Codex, Desktop Codex, Godot, and human review workflows must use that clone unless the human explicitly names another path for a specific task.
- If Codex detects a non-canonical Tiny Cormorant clone, it must warn and stop until the human confirms that clone for the current job.
- Older scratch clones, including `Documents/Codex`, must not silently become the default working copy.

---

## Roles and Handoffs
- The human is the final authority for priority, approval, and scope.
- Epiphanes is the planning and orientation Codex by default. Recommendations, roadmap notes, and draft scopes from Epiphanes are non-executable unless the human explicitly authorizes implementation.
- Physcon is the execution Codex for canonical-clone work by default. Physcon may start a new job only from a complete filled `job.md`, unless the active run already exists and the human explicitly instructs Physcon to continue it.
- Discussion, recommendations, and roadmap thinking must be distinguished from executable job authorization.
- If a prompt is ambiguous, mixes planning advice with implementation instructions, or lacks a complete job template for a new run, Codex must stop and ask.

---

## High-Level Workflow
1. A Git issue or task is identified.
2. The human selects an appropriate job type.
3. For a new executable job, the human provides a complete filled `job.md`.
4. A job instance is created under `codex/runs/`.
5. The job template is stored as `job.md`.
6. Physcon runs the preflight gate from the active clone before making changes.
7. Physcon executes the job strictly within the rules of that job type.
8. Physcon stages only allowed changes.
9. Physcon prints the staged diff review gate.
10. If the staged set is whitelist-clean and no gate violation exists, Physcon runs closeout and writes `results.md`.

Codex must not:
- invent new workflows
- skip templates
- combine unrelated changes
- modify files outside the declared scope
- continue after a git gate stop condition without human resolution
- treat recommendations, roadmap notes, or informal chat summaries as executable job authorization by themselves

---

## Mandatory Git Gates

### Preflight Gate (Required)
Before any implementation or governance edits, Codex must run the preflight gate.

Required commands:
- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Hard stop conditions:
- dirty working tree
- staged changes present
- untracked files present
- branch is behind origin

Codex must not proceed until the tree is clean and the branch is not behind origin.
Hard gate failures must be auditable and machine-detectable where practical, including nonzero script exit codes.

### Review Gate (Required)
Before closeout, Codex must:
1. Stage only allowed files.
2. Run:
   - `git diff --stat --staged`
   - `git diff --staged`
3. Present the staged diff for review logging.

If the staged set includes files outside `codex/runs/ACTIVE_RUN.txt`, `codex/runs/<active-run>/**`, or the active job whitelist, Codex must stop and report the violation.

### Closeout Gate (Required)
If all gates pass and the staged set is whitelist-clean, Codex must close out immediately:
- `git commit -m "<Issue/Task ID>: <Short Title>"`
- `git push --porcelain`

After closeout, Codex must show proof:
- `git log --oneline -n 3`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git status --short`

If the working tree is dirty, the branch is behind origin, or scope is ambiguous, Codex must stop and ask.

---

## Escalation Rule (Large or Risky Changes)
If a patch is:
- larger than about 200 lines changed
- touching more than 3 files
- modifying core systems (for example Customs, GameState, serialization)
- a structural refactor

Codex must pause before staging and present a preview diff:
- `git diff`
- `git diff --stat`

This is a preview gate only when appropriate.
It is not mandatory for small or contained jobs.

---

## Directory Structure
`codex/`
- `README.md` (this file)
- `CONTEXT.md` (project-wide truths and conventions)
- `jobs/` (job types)
  - `feature/`
    - `template.md`
    - `rules.md`
    - `config.md`
  - `bugfix/`
    - `template.md`
    - `rules.md`
    - `config.md`
  - `refactor/`
    - `template.md`
    - `rules.md`
    - `config.md`
  - `governance/`
    - `template.md`
    - `rules.md`
    - `config.md`
- `runs/` (job instances)
  - `ACTIVE_RUN.txt` (name of the active run folder; optional but recommended)
  - `issue-XXXX-jobtype-short-title/`
    - `job.md`
    - `results.md`

---

## Active Run Resolution
Codex must locate the active run folder using this order:
1. If `codex/runs/ACTIVE_RUN.txt` exists, use its contents as the active run folder name.
2. Otherwise, the human must provide the run folder path explicitly.

Codex must not guess which run folder is active.

---

## Job Types (Routing Guide)
Use exactly one job type per task.

### `feature/`
Use when adding new functionality, new flows, or wiring systems into gameplay.

### `bugfix/`
Use when fixing broken behavior, crashes, or regressions with minimal changes.

### `refactor/`
Use when improving structure or readability without functional changes.

### `governance/`
Use when updating Codex process, policy, templates, rules, or other governance assets without changing runtime behavior.

If unsure:
1. `bugfix` if something is broken
2. `feature` if something new is being added
3. `governance` if the change is process or policy only
4. `refactor` only when explicitly improving existing code

If ambiguity remains, Codex must stop and ask.

---

## Required Files for Every Job Instance
Every folder under `codex/runs/` must contain:

### `job.md`
A fully completed job template copied from the selected job type.
This is authoritative.

### `results.md`
Codex must write output here:
- summary of changes
- files modified plus rationale
- assumptions made
- limitations or TODOs

If `results.md` does not exist, Codex is permitted to create it.
No changes should be applied without a corresponding `results.md`.

---

## Authority Order (Highest -> Lowest)
When instructions conflict, obey in this order:
1. `codex/runs/<active-job>/job.md`
2. Job type `rules.md`
3. Job type `config.md`
4. `codex/CONTEXT.md`
5. This README
6. General Codex defaults

---

## Core Principles
- Small blast radius
- Explicit scope
- One job = one concern
- Human-reviewable diffs
- No silent refactors
- One canonical default workspace unless explicitly overridden

If you are about to:
- touch files not listed in the job
- make a judgment call not specified in rules
- refactor while fixing a bug
- add new systems implicitly
- work from a different Tiny Cormorant clone than the canonical default

Stop and ask for clarification.

---

## Hard Rules (Enforced)
- Codex must not modify any files under `codex/` except:
  - `codex/runs/<active-run>/job.md`
  - `codex/runs/<active-run>/results.md`
  - `codex/runs/ACTIVE_RUN.txt`
  - governance files explicitly whitelisted by the active job
- Codex may create a new run folder only when the human has provided a complete job template for the current task and the new paths are allowed by that job.
- Codex must not write `results.md` anywhere except `codex/runs/<active-run>/results.md`.
- Codex must not create, modify, or rely on undocumented clone-selection behavior.
- Codex must not create a run folder from an incomplete job description or mixed planning-and-implementation prompt.
