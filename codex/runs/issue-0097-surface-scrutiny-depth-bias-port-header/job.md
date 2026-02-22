# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0097
- Short Title: Surface heightened-scrutiny (depth bias) in Port header (read-only)
- Run Folder Name: issue-0097-surface-scrutiny-depth-bias-port-header
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
When docked at a port, the player must be able to see whether Customs has "heightened scrutiny" active (i.e., an inspection depth bias) for the current location. This is a read-only perception feature that surfaces existing deterministic inspection depth resolution details without changing inspection behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections remain detection-only: no fines, seizures, holds, tariff collection, cargo mutation, or reputation effects.
- Determinism is preserved: identical world state + tick + context produces identical depth bias and identical displayed text.
- No new time advancement paths are introduced; docked UI interactions must not advance time.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No changes to inspection triggers, roll chances, max-depth selection rules, bias rules/window, audit semantics, classification, or pressure escalation.
- No new UI panels, popups, or banners; only a small addition to the existing Port header.
- No new persistence fields or save/load changes.

---

## Context
`GameState.resolve_customs_inspection_depth(context)` already returns a deterministic inspection depth resolution that includes:
- `max_depth`
- `depth_bias`
- `reasons` (including a "Heightened scrutiny ..." reason when bias is active)

`Customs` uses this centralized resolver to determine inspection depth and already emits a log line when heightened scrutiny is applied during an inspection. However, the player currently has no *at-a-glance* visibility of heightened scrutiny while docked, before an inspection triggers.

A read-only indicator in the Port header would support the "perception before simulation" philosophy by making scrutiny legible.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Extend the existing Port header rendering to include a single new line: "Customs scrutiny: Normal" or "Customs scrutiny: Heightened (+1 depth)".
- Source this value from `GameState.resolve_customs_inspection_depth({system_id, location_id})` (or existing Port context values).
- Use only the already-computed `depth_bias` field; do not re-implement bias logic in UI.
- Ensure the header line is stable, deterministic, and does not advance time or emit logs.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://scripts/Port.gd`
- `res://singletons/GameState.gd` (read-only access/wiring only if needed; no gameplay rule changes)

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
If none, write "None".

- None.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Fully backward compatible
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - The displayed Port header scrutiny line for a given state/tick/location.
- What inputs must remain stable?
  - `system_id`, `location_id`, `time_tick`, and the existing Level-2 violation memory already stored in GameState.
- What must not introduce randomness or time-based variance?
  - No RNG; no wall-clock time; no unordered iteration when formatting output.

---

## Acceptance Criteria (Must Be Testable)
These define "done" and must be objectively verifiable.

- [ ] When docked, Port header displays a "Customs scrutiny" line that reflects the current location's `depth_bias`.
- [ ] If `depth_bias` is 0, the line reads "Normal" (or equivalent); if >0, the line reads "Heightened (+N depth)" (or equivalent).
- [ ] The change does not advance time, change inspection outcomes, or introduce additional logs.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Dock at a location with no recent Level-2 invariant violations; confirm Port header shows "Customs scrutiny: Normal".
2. Trigger a Level-2 inspection that produces invariant violations at the same location; return/dock (or remain docked if applicable) and confirm Port header shows "Customs scrutiny: Heightened (+1 depth)".
3. Advance time beyond the configured bias window and confirm the header returns to "Normal" (if your flow allows time advancement past the window).

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing/empty `system_id` or `location_id` in Port context: show a safe fallback like "Customs scrutiny: Unknown" and do not crash.
- If `resolve_customs_inspection_depth()` returns `ok=false`, show "Unknown" (no exceptions).
- If `depth_bias` is malformed/non-int, treat as 0 and show "Normal".

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- UI must not duplicate or re-implement depth bias rules; it should only display the resolved value.
- Port header layout must remain readable; keep the new line short.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
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
  B) Run the current issue's Closeout Gate (stage -> staged diff review -> commit -> push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/**`
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
  - `git commit -m "issue-0097: Surface heightened-scrutiny (depth bias) in Port header (read-only)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/`
2) Write this job verbatim to `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/job.md`
3) Create `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0097-surface-scrutiny-depth-bias-port-header`

Codex must write final results only to:
- `codex/runs/issue-0097-surface-scrutiny-depth-bias-port-header/results.md`

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