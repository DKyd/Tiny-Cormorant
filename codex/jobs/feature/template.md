# Feature Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:
- Job Type: feature
- Author (human):
- Date:

---

## Goal
Describe the desired outcome in 1–3 sentences.  
Focus on player-facing or system-facing behavior, not implementation.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- 
- 
- 

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- 
- 

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ⬅️ NEW

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
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- 
- 

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- 
- 

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - 
- Migration / backward-compat expectations:
  - 
- Save/load verification requirements:
  - 

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
- What inputs must remain stable?
- What must not introduce randomness or time-based variance?

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ]
- [ ]
- [ ]

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1.
2.
3.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- 
- 

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- 
- 
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ⬅️ NEW

---

## Governance & Review Gates (Mandatory) ⬅️ NEW
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
  - `codex/runs/<Run Folder Name>/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- STOP and wait for the user’s explicit approval.

2) Closeout Gate (Commit + Push)
- Only after the user replies exactly: “Green light: commit and push”
- Run:
  - `git commit -m "<Issue/Task ID>: <Short Title>"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
