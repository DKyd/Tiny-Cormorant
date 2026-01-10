# Codex Job System — Tiny Cormorant

This directory defines how **Codex** is used to make controlled, reviewable changes to the Tiny Cormorant codebase.

Codex is **not allowed to make free-form changes** to the repository.  
All work must be performed through a **job** created from a predefined **job type**.

If Codex is unsure which job type applies, it must **stop and ask** rather than guess.

Note: `codex/` is treated as governance and is read-only to Codex, except for the active run folder where `job.md` and `results.md` live.

---

## High-Level Workflow

1. A Git issue or task is identified.
2. The human selects an appropriate **job type**.
3. A **job instance** is created under `codex/runs/`.
4. The job template is filled out completely.
5. Codex executes the job **strictly within the rules of that job type**.
6. Results are reviewed and either accepted or revised.

Codex **must not**:
- invent new workflows
- skip templates
- combine unrelated changes
- modify files outside the declared scope

---

## Directory Structure

codex/
├─ README.md ← This file (routing + rules of engagement)
├─ CONTEXT.md ← Project-wide truths and conventions
├─ jobs/ ← Job TYPES (how work is defined)
│ ├─ feature/
│ │ ├─ template.md
│ │ ├─ rules.md
│ │ └─ config.json
│ ├─ bugfix/
│ │ ├─ template.md
│ │ ├─ rules.md
│ │ └─ config.json
│ └─ refactor/
│ ├─ template.md
│ ├─ rules.md
│ └─ config.json
└─ runs/ ← Job INSTANCES (one per task/issue)
└─ issue-XXXX-short-title/
├─ job.md
├─ notes.md (optional)
└─ results.md (Codex output)

yaml
Copy code

---

## Job Types (Routing Guide)

Use **exactly one** job type per task.

### 1. `feature/`
Use when:
- Adding new gameplay systems
- Adding new UI panels or flows
- Introducing new mechanics, data models, or interactions

Do **not** use for:
- Pure cleanup
- Bug fixes without new functionality

---

### 2. `bugfix/`
Use when:
- Fixing broken behavior
- Resolving errors, crashes, or incorrect logic
- Addressing regressions

Rules of thumb:
- Minimal change
- No refactors unless explicitly required
- No new features

---

### 3. `refactor/`
Use when:
- Improving structure, readability, or organization
- Renaming for clarity
- Reducing duplication or technical debt

Hard rule:
- **No functional changes** allowed

---

## If You Are Unsure Which Job Type to Use

Default to:

1. **bugfix** if something is broken
2. **feature** if something new is being added
3. **refactor** only when explicitly improving existing code

If ambiguity remains, Codex must stop and request clarification.

---

## Required Files for Every Job Instance

Every folder under `codex/runs/` **must contain**:

### `job.md`
A fully completed job template copied from the selected job type.

This file defines:
- The goal
- Allowed and forbidden files
- Non-goals
- Acceptance criteria
- Constraints

Codex must treat `job.md` as **authoritative**.

---

### `results.md`
Codex must write its output here, including:

- Summary of changes
- List of files modified
- Rationale per file
- Any assumptions made
- Any remaining risks or TODOs

No changes should be applied without a corresponding `results.md`.

---

## Authority Order (Highest → Lowest)

When instructions conflict, Codex must obey them in this order:

1. `job.md`
2. Job type `rules.md`
3. Job type `config.json`
4. `CONTEXT.md`
5. This README
6. General Codex defaults

---

## Core Principles

- **Small blast radius**
- **Explicit scope**
- **One job = one concern**
- **Human-reviewable diffs**
- **No silent refactors**

Codex is a power tool, not an author.  
All creativity flows through constraints.

---

## Final Note to Codex

If you are about to:
- Touch files not listed in the job
- Make a judgment call not specified in rules
- Refactor while fixing a bug
- Add new systems implicitly

**Stop.**  
Ask for clarification before proceeding.
