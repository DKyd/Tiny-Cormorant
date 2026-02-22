# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0098
- Short Title: Surface scrutiny + final max depth details in inspection preview (advisory)
- Run Folder Name: issue-0098-surface-scrutiny-in-inspection-preview
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
When the player views the advisory inspection preview, the preview text must clearly communicate Customs scrutiny state (Normal vs Heightened) and the final resolved max inspection depth (after applying any depth bias and clamping). This makes “heightened scrutiny” legible at the decision point without adding enforcement, penalties, or UI flows.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections remain detection-only: no fines, seizures, holds, confiscation, or reputation effects.
- Deterministic behavior is preserved: identical world state produces identical preview text content (including ordering).
- No new per-frame or loop-driven log/UI spam is introduced; preview updates remain event-driven.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No changes to inspection trigger logic, Level-2 audit semantics, invariant rules, evidence flags, classification labels, or pressure escalation rules.
- No new UI panels/banners or interaction flows; only improve the text surfaced in the existing inspection preview display.

---

## Context
- `GameState.resolve_customs_inspection_depth(context)` returns a Dictionary including:
  - `max_depth` (final, after depth_bias + clamp)
  - `depth_bias`
  - `reasons` (Array of human-readable explanations, including heightened scrutiny when active)
- `scripts/Port.gd` already calls `GameState.resolve_customs_inspection_depth(...)` for the Port header and displays:
  - “Customs scrutiny: Normal” or “Heightened (+N depth)”
  - “Inspection preview (advisory): …”
- The preview line currently does not reliably include both:
  - scrutiny state, and
  - the final resolved max_depth (as distinct from base pressure depth).

We want the existing “Inspection preview (advisory)” output to be explicit and self-contained about scrutiny + final depth.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ⬅️ NEW

- Identify where the advisory “Inspection preview” text is constructed (currently in `scripts/Port.gd`).
- Ensure the preview text includes:
  - base pressure bucket depth (if already shown),
  - scrutiny state and bias (+N),
  - final resolved `max_depth`.
- Prefer reusing `resolve_customs_inspection_depth(...).reasons` (stable order) rather than inventing a new formatting system.
- Keep wording concise (single preview block/line), stable, and deterministic.
- Do not add new logs; this is UI-only text.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://scripts/Port.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

- N/A

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Fully backward compatible
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
  - The advisory preview text content and ordering for identical resolved preview output.
- What inputs must remain stable?
  - `resolve_customs_inspection_depth(...)` fields (`likelihood`, `depth_bias`, `max_depth`, `reasons`).
- What must not introduce randomness or time-based variance?
  - No timestamps, no RNG, no unordered Dictionary iteration for composing display strings.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The advisory inspection preview text explicitly communicates scrutiny state (Normal vs Heightened with +N bias when applicable).
- [ ] The advisory inspection preview text explicitly communicates the final resolved `max_depth` (post-bias and clamp).
- [ ] No gameplay behavior changes: triggers, audits, classifications, and pressure escalation are unchanged.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save (or start a run) and open a Port where the advisory inspection preview is shown.
2. In a “Normal” scenario (no recent Level-2 violations), verify preview text includes scrutiny = Normal and final `max_depth`.
3. Create a “Heightened” scenario (trigger Level-2 violations at the same location, then re-open Port within the configured window) and verify preview text includes scrutiny = Heightened (+1) and updated final `max_depth`.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- If `resolve_customs_inspection_depth(...)` returns `ok=false`, preview should show “Unknown” safely and not crash.
- If `reasons` is missing or malformed, preview should fall back to a minimal safe message (bucket + max_depth if available).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: duplicating information (Port header already shows scrutiny). Keep preview concise and decision-facing (final depth).
- Ensure preview string composition doesn’t depend on Dictionary iteration order.
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
  - `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/**`
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
  - `git commit -m "issue-0098: Surface scrutiny + final max depth in inspection preview (advisory)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/`
2) Write this job verbatim to `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/job.md`
3) Create `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0098-surface-scrutiny-in-inspection-preview`

Codex must write final results only to:
- `codex/runs/issue-0098-surface-scrutiny-in-inspection-preview/results.md`

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