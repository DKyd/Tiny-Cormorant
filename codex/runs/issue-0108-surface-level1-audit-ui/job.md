# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0108
- Short Title: Surface Level 1 audit UI readout
- Run Folder Name: issue-0108-surface-level1-audit-ui
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Expose the existing **Level 1 surface compliance audit payload** to the player in a clear, non-intrusive way (UI and/or log), so players can understand *what would be flagged* before deeper enforcement systems exist.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 1 checks remain **non-enforcing** (no blocking travel, no cargo mutation, no penalties).
- Audit generation remains **deterministic** for the same inputs (no time-based or random variance introduced).
- No changes to `data/**` or other forbidden paths; no content/data edits to “make the UI look good.”

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No Level 2 logic, cross-document invariants, or “deep” inspection expansion.
- No gameplay consequences (fines, seizure, denial of docking, forced re-routing, reputation hits, etc.).

---

## Context
Level 1 surface compliance checks and an audit payload exist (formalized in issue-0107). However, the player currently lacks a visible/readable presentation of that audit output during normal gameplay, making it hard to understand compliance status and debug/document gameplay decisions.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a UI readout location (likely within Port / Captain’s Quarters / Market context) to display the **latest Level 1 audit summary** for the current location/cargo/docs.
- Display a concise “PASS/WARN” header plus a structured list of surfaced findings (human-readable strings).
- Ensure UI display is **pull-based** (reads existing payload) and does not alter audit computation.
- Add minimal logging for explicit player actions that request/refresh the audit view (no per-frame spam).
- Keep visuals simple and consistent with existing UI; avoid layout refactors outside the minimal needed.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/ui/CustomsInspectionPanel.tscn`
- `scenes/ui/SurfaceAuditPanel.tscn`
- `scripts/ui/CustomsInspectionPanel.gd`
- `scripts/ui/SurfaceAuditPanel.gd`
- `scripts/Port.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `scenes/ui/SurfaceAuditPanel.tscn`
- `scripts/ui/SurfaceAuditPanel.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New UI script method (example): `SurfaceAuditPanel.set_audit(audit_payload: Dictionary) -> void`
- None outside UI layer (Customs/GameState APIs unchanged)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - N/A

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - The displayed audit content must match the underlying Level 1 payload deterministically for identical inputs.
- What inputs must remain stable?
  - Current location context, active docs/cargo snapshot used by Level 1 audit.
- What must not introduce randomness or time-based variance?
  - UI refresh must not recompute using “current time” or tick drift; it should render the payload as-produced.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When the player opens the relevant UI context, a **Surface Audit** readout appears and shows the latest Level 1 audit status (PASS/WARN + findings list).
- [ ] The readout is **non-enforcing**: player can proceed normally regardless of WARN findings.
- [ ] The audit readout updates on an explicit player action (open panel / press refresh) without introducing per-frame log spam.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and load into a port/location where market/docs are accessible.
2. Open the UI context that hosts the Surface Audit panel (Port/Captain’s Quarters/etc.).
3. Verify the Surface Audit panel renders (header + findings list) and is readable.
4. Change documents/cargo state in a way that should affect Level 1 surface checks (e.g., declared qty mismatch, missing required field if available).
5. Refresh/reopen the Surface Audit panel and confirm the findings update accordingly.
6. Confirm no penalties or blocking behavior occurs; confirm logs are only emitted on explicit refresh/open actions.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Audit payload missing/empty ? UI shows “No audit available” and does not error.
- Unexpected payload shape/fields ? UI displays a safe fallback string and logs a single diagnostic entry (no spam).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- UI placement risk: attaching a new panel to an unstable part of the UI could cause merge conflicts with ongoing UI cleanup work.
- Payload coupling risk: UI must not “reach into” deep systems or trigger recomputation outside intended calls.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory) ?? NEW
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
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
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
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/<Run Folder Name>/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
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


