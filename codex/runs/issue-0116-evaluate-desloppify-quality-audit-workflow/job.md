# Governance Job

## Metadata (Required)
- Issue/Task ID: issue-0116
- Short Title: Evaluate Desloppify quality audit workflow
- Run Folder Name: issue-0116-evaluate-desloppify-quality-audit-workflow
- Job Type: governance
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Evaluate whether Desloppify should become part of the Tiny Cormorant quality-audit workflow. Run it as a diagnostic tool only, capture exclusions/findings/risks, and recommend whether future Desloppify findings should be converted into normal governed jobs.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

- No runtime game behavior may change.
- Desloppify findings must not be fixed during this job.
- `.desloppify/**` local tool state must not be committed.
- Tiny Cormorant’s existing job whitelist and review gate discipline must remain authoritative over any external tool recommendation.
- The canonical workspace remains `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`.

---

## Non-Goals
Hard scope boundaries.

- Do not refactor, clean up, rename, or otherwise modify gameplay/runtime code.
- Do not resolve Desloppify issues during this job.
- Do not tune the score by marking findings false-positive/wontfix unless explicitly documenting why in `results.md`.
- Do not add Desloppify badges, CI checks, or required pass/fail thresholds.
- Do not commit generated Desloppify state, caches, reports, or external dependency folders.

---

## Context
Desloppify is an external Python CLI/agent harness for codebase quality scanning and technical-debt tracking. It supports GDScript and can identify issues such as dead code, duplication, complexity, naming drift, and structural/code-quality concerns.

Tiny Cormorant already has strict governance: Codex work is job-scoped, whitelist-bound, reviewed through staged diffs, and committed only after gates pass. Desloppify’s default agent loop encourages broad cleanup and refactoring, which may be useful diagnostically but must not override Tiny Cormorant’s governance model.

This job exists to evaluate Desloppify safely as an audit/triage input, not as an autonomous cleanup authority.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST: Treat Desloppify as advisory unless a future governance job explicitly adopts it into the project workflow.
- MUST: Run Desloppify only from the canonical workspace unless the human explicitly authorizes another clone.
- MUST: Exclude obvious generated/local/tooling directories before scanning.
- MUST: Record scan commands, exclusions, score/output summary, notable findings, limitations, and recommendations in `results.md`.
- MUST: Convert any proposed code cleanup into future normal Tiny Cormorant jobs with whitelists and review gates.
- MUST NOT: Modify runtime code to satisfy Desloppify during this evaluation job.
- MUST NOT: Commit `.desloppify/**`.
- MUST NOT: let Desloppify’s “next” queue override active job scope, blacklist rules, or human review gates.

---

## Proposed Approach
High-level plan (3–6 bullets). Boundaries only.

- Confirm clean canonical clone preflight before installing or running tooling.
- Install or invoke Desloppify in the least invasive practical way.
- Add `.desloppify/` to `.gitignore` only if it is not already ignored.
- Identify and apply obvious scan exclusions such as `.git/`, `.godot/`, `.desloppify/`, and generated/cache directories.
- Run a Desloppify scan against the project, preferably with GDScript support enabled or detected.
- Summarize findings and recommend whether/how Desloppify should become part of future governance.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `.gitignore` only to add `.desloppify/` if missing
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/job.md`
- `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/results.md`

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
- `codex/AGENTS.md`
- `codex/README.md`
- `codex/CONTEXT.md`
- `codex/jobs/**`
- Any dependency/vendor/cache directories created by package tooling

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/job.md`
- `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/results.md`

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable “done.”

- [ ] Preflight confirms the canonical clone is clean and not behind origin before tool work begins.
- [ ] `.desloppify/` is ignored by git, either because it already was or because this job adds it to `.gitignore`.
- [ ] Desloppify scan commands and exclusions are recorded in `results.md`.
- [ ] `results.md` includes score/output summary, notable findings, limitations, and a recommendation for future use.
- [ ] No Desloppify findings are fixed during this job.
- [ ] No files outside the whitelist are modified or staged.

---

## Verification Steps (Non-Game)
How a human verifies the governance change (reading files and/or git commands).

1. Run `git status --short` and confirm only whitelisted files are modified/staged.
2. Confirm `.desloppify/` is ignored and no `.desloppify/**` files are staged.
3. Read `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/results.md` and confirm it includes commands, exclusions, findings, limitations, and recommendation.
4. Run `git diff --stat` and full `git diff` and confirm no runtime files changed.
5. Confirm any future cleanup is described as proposed follow-up jobs, not performed in this job.

---

## Risks / Notes
- Desloppify may require network access and Python 3.11+ installation support.
- Desloppify may create local state under `.desloppify/`; this must remain uncommitted.
- Subjective/LLM review features may send code or summaries outside the local machine depending on configuration; if unclear, Codex must stop and report before using those features.
- If Desloppify output is noisy or unreliable for Godot/GDScript, record that limitation rather than forcing adoption.
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
  - `.gitignore` if changed only to add `.desloppify/`
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/**`
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately.
- STOP conditions (user input required):
  - Working tree is dirty outside allowed local Desloppify state.
  - Branch is behind origin.
  - Staged set includes files outside `.gitignore`, ACTIVE_RUN.txt, or this run folder.
  - `.desloppify/**` is staged.
  - Runtime files are modified.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0116: Evaluate Desloppify quality audit workflow"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean except ignored `.desloppify/` local state)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes:

1) Create `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/`
2) Write this job verbatim to `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/job.md`
3) Create `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0116-evaluate-desloppify-quality-audit-workflow`

Codex must write final results only to:
- `codex/runs/issue-0116-evaluate-desloppify-quality-audit-workflow/results.md`
