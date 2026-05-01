# Governance Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:
- Job Type: governance
- Author (human):
- Date:

---

## Goal
Describe the governance outcome in 1-3 sentences.
Focus on process or policy behavior, not implementation.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

-
-
-

---

## Non-Goals
Hard scope boundaries.

-
-

---

## Context
What happened, what risk it created, and why this governance change is needed.
Do not propose solutions here.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST:
- MUST NOT:

---

## Proposed Approach
High-level plan (3-6 bullets). Boundaries only.

-
-
-

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

-
-

---

## Files: Forbidden to Modify (Blacklist)
These files or directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- `.godot/**`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable "done."

- [ ]
- [ ]
- [ ]

---

## Verification Steps (Non-Game)
How a human verifies the governance change by reading files and or running git commands.

1.
2.
3.

---

## Risks / Notes
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make changes until required preflight and review steps are complete.
- Codex must present diffs for review before declaring results final.
- Gate B approvals must include scope proof (`git status`, `git diff --stat`, full `git diff`).
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
- Hard preflight failures should be machine-detectable where practical, including nonzero script exit codes.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage only:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/<Run Folder Name>/**`
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
  - Staged set includes files outside `ACTIVE_RUN.txt`, `codex/runs/<Run Folder Name>/**`, or the job whitelist.
  - Scope, whitelist, or blacklist instructions conflict or are ambiguous.
- Run:
  - `git commit -m "<Issue/Task ID>: <Short Title>"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- Stop.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes when the human has provided a complete job template:

1. Create `codex/runs/<Run Folder Name>/`
2. Write the job text verbatim to `codex/runs/<Run Folder Name>/job.md`
3. Create `codex/runs/<Run Folder Name>/results.md` if missing
4. Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`
