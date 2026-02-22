# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0095
- Short Title: Deterministic inspection-depth bias from prior Level-2 violations (no enforcement)
- Run Folder Name: issue-0095-deterministic-inspection-depth-bias-from-violations
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
When a Customs inspection is evaluated, the system must deterministically bias the maximum inspection depth upward based on the ship/location’s recent history of Level-2 invariant violations. This introduces ’heightened scrutiny’ as a soft consequence that only affects future inspection depth selection, without adding enforcement, penalties, or UI.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections remain detection-only: no fines, seizures, holds, tariff collection, cargo mutation, or reputation effects.
- Determinism is preserved: identical world state + tick + context produces identical inspection depth selection.
- No per-frame or loop-driven behavior/log spam is introduced; any new logic runs only during inspection resolution / depth selection.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No changes to Level-2 audit semantics, invariant rules, evidence flags, classification labels, or pressure escalation rules.
- No UI changes (no new banners/panels) and no new player interaction flows.
- No new persistence fields unless strictly required to remember ’recent violation history’; do not expand save schema unless unavoidable.

---

## Context
Customs inspections already:
- run deterministically
- support depth >= 2 Level-2 audits
- populate `report["invariant_violations"]`
- surface a Level-2 invariant summary in CUSTOMS logs (issue-0094)

However, invariant violations currently do not feed back into the *next* inspection’s depth selection. The game lacks a ’soft consequence’ layer where contradictions increase scrutiny (more frequent deeper inspections) without introducing enforcement.

This job adds a deterministic ’scrutiny bias’ input to inspection depth selection derived from prior detected Level-2 invariant violations.

---

## Proposed Approach
A short, high-level plan (3’6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ⬅️ NEW

- Identify the existing inspection depth selection point (where max_depth is decided) and add an additive bias term derived from recent invariant-violation history.
- Define a small, deterministic ’recent violations window’ (e.g., last N inspections or last N ticks) and a capped bias mapping (e.g., +0/+1 only).
- Record invariant-violation outcomes from inspections into an existing or minimal new state container (only if required), keyed by location_id (or another stable key already used by Customs pressure).
- Ensure bias affects only depth selection, not triggers, classification, or pressure.
- Emit one CUSTOMS log line when bias is applied (e.g., ’Heightened scrutiny: +1 depth due to recent Level-2 violations’), without spam.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

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
If none, write ’None’.

- None (preferred).
- If unavoidable: add a clearly scoped helper for reading ’recent violation history’ that remains internal/private.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - Prefer none.
  - If required: a small, bounded per-location ’recent invariant violation’ memory (e.g., last_violation_tick and/or a bounded queue of recent outcomes).
- Migration / backward-compat expectations:
  - Must be backward compatible (missing fields treated as empty / no bias).
- Save/load verification requirements:
  - Load older saves without errors.
  - Bias state (if persisted) round-trips correctly.

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
  - The inspection depth bias decision and final chosen max_depth.
- What inputs must remain stable?
  - location_id/system_id, action, time_tick, and the recorded violation history data.
- What must not introduce randomness or time-based variance?
  - No RNG; no dependence on wall-clock time; no unordered iteration. Any history window evaluation must be stable and bounded.

---

## Acceptance Criteria (Must Be Testable)
These define ’done’ and must be objectively verifiable.

- [ ] After an inspection that produces non-empty `invariant_violations`, a subsequent inspection at the same location deterministically applies a depth bias (within defined window/caps).
- [ ] If there are no recent invariant violations, no depth bias is applied.
- [ ] Bias only affects inspection max_depth selection; audit semantics, classification, and pressure escalation remain unchanged.
- [ ] A single CUSTOMS log entry indicates when a bias is applied (and what the bias was), without introducing spam.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Trigger an inspection at depth >= 2 with clean documents; confirm no ’heightened scrutiny’ bias log appears on the next inspection.
2. Trigger an inspection that yields at least one invariant violation; then trigger another inspection at the same location within the configured window; confirm:
   - bias log appears
   - chosen max_depth is increased or clamped as designed
3. Save and reload (if bias state is persisted) and re-run the follow-up inspection; confirm identical bias behavior and logs.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or malformed `invariant_violations` in a report must not crash; treat as ’no violations recorded’.
- If history container exceeds bounds, it must clamp/evict deterministically.
- If bias would push depth above allowed max, clamp deterministically.
- New saves/old saves missing fields must behave as ’no bias’.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Depth-selection logic is a sensitive choke point; ensure no hidden behavior change to triggers or classification.
- Persistence risk: adding save fields can cause churn; prefer in-memory only unless design requires cross-session memory.
- Ensure any new log line is emitted only when bias is applied.
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
  - `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/**`
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
  - `git commit -m "issue-0095: Deterministic inspection-depth bias from prior Level-2 violations (no enforcement)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/`
2) Write this job verbatim to `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/job.md`
3) Create `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0095-deterministic-inspection-depth-bias-from-violations`

Codex must write final results only to:
- `codex/runs/issue-0095-deterministic-inspection-depth-bias-from-violations/results.md`

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
