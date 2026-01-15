# Codex Job System — Tiny Cormorant

This directory defines how **Codex** is used to make controlled, reviewable changes to the Tiny Cormorant codebase.

Codex is **not allowed to make free-form changes** to the repository.
All work must be performed through a **job** created from a predefined **job type**.

`codex/` is governance and is read-only to Codex **except** for the active run folder where `job.md` and `results.md` live.

---

## High-Level Workflow

1. A Git issue or task is identified.
2. The human selects an appropriate **job type**.
3. A **job instance** is created under `codex/runs/`.
4. The job template is filled out completely as `job.md`.
5. Codex executes the job strictly within the rules of that job type.
6. Codex writes `results.md` in the run folder.
7. Human reviews diffs and either accepts or requests revisions.

Codex must not:
- invent new workflows
- skip templates
- combine unrelated changes
- modify files outside the declared scope

---

## Directory Structure

codex/
- README.md        (this file)
- CONTEXT.md       (project-wide truths and conventions)
- jobs/            (job TYPES)
  - feature/
	- template.md
	- rules.md
	- config.json
  - bugfix/
	- template.md
	- rules.md
	- config.json
  - refactor/
	- template.md
	- rules.md
	- config.json
- runs/            (job INSTANCES)
  - ACTIVE_RUN.txt (name of the active run folder; optional but recommended)
  - issue-XXXX-jobtype-short-title/
	- job.md
	- results.md

---

## Active Run Resolution (Important)

Codex must locate the active run folder using this order:

1) If `codex/runs/ACTIVE_RUN.txt` exists, use its contents as the active run folder name.
2) Otherwise, the human must provide the run folder path explicitly.

Codex must not guess which run folder is active.

---

## Job Types (Routing Guide)

Use exactly one job type per task.

### feature/
Use when adding new functionality, new flows, or wiring systems into gameplay.

### bugfix/
Use when fixing broken behavior, crashes, or regressions with minimal changes.

### refactor/
Use when improving structure/readability without functional changes.

If unsure:
1) bugfix if something is broken
2) feature if something new is being added
3) refactor only when explicitly improving existing code

If ambiguity remains, Codex must stop and ask.

---

## Required Files for Every Job Instance

Every folder under `codex/runs/` must contain:

### job.md
A fully completed job template copied from the selected job type.
This is authoritative.

### results.md
Codex must write output here:
- summary of changes
- files modified + rationale
- assumptions made
- limitations / TODOs

If `results.md` does not exist, Codex is permitted to create it.
No changes should be applied without a corresponding `results.md`.

---

## Authority Order (Highest → Lowest)

When instructions conflict, obey in this order:

1. `codex/runs/<active-job>/job.md`
2. Job type `rules.md`
3. Job type `config.json`
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

If you are about to:
- touch files not listed in the job
- make a judgment call not specified in rules
- refactor while fixing a bug
- add new systems implicitly

Stop and ask for clarification.

## Hard Rules (Enforced)

- Codex must not modify any files under `codex/` **except**:
  - `codex/runs/<active-run>/job.md`
  - `codex/runs/<active-run>/results.md`
- Codex must not create new run folders. Only the human creates run folders.
- Codex must not write `results.md` anywhere except `codex/runs/<active-run>/results.md`.

## Active Run Resolution (Important)

Codex must locate the active run folder using this order:

1) If `codex/runs/ACTIVE_RUN.txt` exists, use its contents as the active run folder name.
2) Otherwise, the human must provide the run folder path explicitly.

If neither (1) nor (2) is available, Codex must STOP and ask for the active run folder.
Codex must not guess which run folder is active.
