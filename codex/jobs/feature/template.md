# Feature Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:            # REQUIRED (e.g. issue-0018-feature-detailed-map-headers)
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
Describe intent and boundaries, not specific code structure.

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
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - 
- Migration / backward-compat expectations:
  - 
- Save/load verification requirements:
  - 

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
