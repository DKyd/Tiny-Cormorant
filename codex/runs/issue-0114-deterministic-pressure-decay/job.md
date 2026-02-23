# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0114
- Short Title: Deterministic pressure decay policy
- Run Folder Name: issue-0114-deterministic-pressure-decay
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Implement a deterministic, tunable decay model so customs scrutiny/pressure does not only ratchet upward. After scrutiny escalation, advancing time (or completing travel) must reduce stored scrutiny deltas predictably with stable constants and without randomness.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Pressure/scrutiny updates remain deterministic (same inputs/state -> same outputs).
- No new randomness or wall-clock dependence is introduced into pressure/scrutiny behavior.
- Time still advances only through `GameState.advance_time(reason)` (no UI-driven time advance).

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Do NOT change inspection chance logic, bucket thresholds, or inspection triggers (only decay of stored pressure/scrutiny values).
- Do NOT change Level 1/Level 2 audit logic, invariant definitions, or enforcement behavior.
- Do NOT add new UI, notifications, or player-facing messages beyond existing logs (unless logs already exist for time advance).

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- The game tracks customs scrutiny/pressure per location and uses it to determine inspection probability and/or inspection depth bias.
- Current scrutiny/pressure behavior is primarily ratcheting upward based on events/violations, with limited or no decay over time.
- Under the updated North Star and roadmap, scrutiny should be able to cool down over time deterministically, using a simple policy that can be tuned later via constants and a single function entrypoint.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ?? NEW

- Locate the canonical persisted/customary store of customs pressure/scrutiny deltas (expected in `singletons/GameState.gd` customs state).
- Add a single decay function (with constants near the function) that applies a small deterministic decrement to stored scrutiny deltas/pressure components while clamping at 0.
- Invoke the decay function in exactly one deterministic place:
  - on `GameState.advance_time(reason)` OR
  - on travel completion (if travel completion is the only consistent “time step” in the current design).
- Ensure decay is stable regardless of frame rate and does not depend on real time; it must use tick deltas already tracked by GameState.
- Keep implementation minimal and easy to tune (constants + one function), and log the decay application only if existing time-advance logging expects it (no spam).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Customs.gd` (only if strictly necessary to keep call sites consistent; prefer no change)

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

- `codex/runs/issue-0114-deterministic-pressure-decay/job.md`
- `codex/runs/issue-0114-deterministic-pressure-decay/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None (decay function may be private/internal)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ?? NEW

- New or changed saved fields:
  - None required (prefer operating on existing persisted scrutiny/pressure fields).
- Migration / backward-compat expectations:
  - Existing saves must continue to load; decay should apply to existing stored values without requiring migration.
- Save/load verification requirements:
  - Load a save with elevated scrutiny, advance time, save, reload, and confirm the decayed values persist deterministically.

---

## Determinism & Stability (If Applicable) ?? NEW
- What must be deterministic?
  - The exact decay amount per tick (or per discrete time-advance event) and the resulting stored values.
- What inputs must remain stable?
  - Tick delta used for decay (e.g., `advance_time` tick increment), per-location stored scrutiny deltas.
- What must not introduce randomness or time-based variance?
  - No random rolls, no system clock time, no per-frame updates.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] After scrutiny/pressure is increased, advancing time reduces stored scrutiny deltas/pressure predictably (same tick delta -> same decay).
- [ ] Decay is tunable via constants in one place and clamps values at 0 (never negative).
- [ ] No inspection chance logic, bucket thresholds, or triggers are changed; only decay of stored values is introduced.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Create or load a save where customs pressure is Elevated/High (or force a Level 2 violation to raise scrutiny).
2. Note the current customs pressure/scrutiny values (via any existing debug print/log/UI indicator) and the current bucket.
3. Advance time via a normal gameplay action that calls `GameState.advance_time(reason)` (or complete a travel step if that’s where decay is applied).
4. Confirm the stored scrutiny/pressure values decreased deterministically and the bucket can eventually step down with repeated time advances.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing/partial customs state for a location: decay must not crash; it should skip or initialize safely without inventing new schema.
- Very large tick deltas: decay must clamp at 0 and remain stable (no underflow).
- Locations without any scrutiny history: decay should be a no-op.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: There may be multiple “pressure” representations (bucket vs numeric vs deltas); Codex must identify the canonical stored source and only decay that source.
- Risk: Applying decay at the wrong hook could unintentionally change pacing; keep the initial decay conservative and easily tunable.
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ?? NEW

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
  - `codex/runs/issue-0114-deterministic-pressure-decay/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0114-deterministic-pressure-decay/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0114: Deterministic pressure decay policy"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0114-deterministic-pressure-decay/`
2) Write this job verbatim to `codex/runs/issue-0114-deterministic-pressure-decay/job.md`
3) Create `codex/runs/issue-0114-deterministic-pressure-decay/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0114-deterministic-pressure-decay`

Codex must write final results only to:
- `codex/runs/issue-0114-deterministic-pressure-decay/results.md`

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
