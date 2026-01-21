# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0060
- Short Title: Inspection & Customs Pressure Indicators (Read-Only)
- Run Folder Name: issue-0060-inspection-pressure-readonly
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-21

---

## Goal
Surface read-only indicators that communicate inspection or customs pressure to the player, making enforcement risk legible without introducing inspections, randomness, or simulation.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- No inspections, enforcement actions, or penalties are introduced.
- No randomness, ticking, or time-based simulation is added.
- UI surfaces may display risk or pressure but must not decide outcomes.
- Existing legality, market access, and organization influence behavior remains unchanged.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No actual inspections, searches, confiscation, or fines.
- No changes to freight legality, markets, or pricing.
- No persistence changes or save/load schema modifications.
- No probabilistic systems or hidden rolls.

---

## Context
Tiny Cormorant already models deterministic world facts such as organization influence, legality, and time passage. Recent work (Issues 0056–0058) introduced organization influence and made it legible without simulation.

What is currently missing is any player-facing indication that time, cargo composition, and organizational presence create *pressure* or scrutiny. Enforcement exists conceptually but is not yet perceptible to the player.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only.

- Derive a read-only “inspection pressure” or “customs scrutiny” indicator from existing world facts.
- Present this indicator in an existing UI context (e.g., Port header or inspector text).
- Use descriptive buckets (e.g., Low / Elevated / High) rather than numeric probabilities.
- Ensure the indicator is deterministic and stable for a given state.
- Avoid introducing any new mechanics, decisions, or side effects.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/Port.gd`
- `scripts/ui/*`
- `singletons/GameState.gd` (read-only query helpers only, no state mutation)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None (any helper queries must be private or internal)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not applicable
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- Inspection pressure indicators must be derived deterministically from existing state.
- Inputs such as organization influence, cargo flags, and time counters must remain stable.
- No randomness, timers, or per-tick variance may be introduced.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Port UI displays a read-only inspection/customs pressure indicator.
- [ ] Indicator values remain stable across reloads for the same game state.
- [ ] No new gameplay effects, logs, or enforcement actions occur.
- [ ] Removing or hiding the indicator does not affect gameplay behavior.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save and visit multiple locations with different org presence or cargo states.
2. Open Port and observe the inspection/customs pressure indicator.
3. Reload the game and revisit the same locations; confirm indicator stability.
4. Confirm no inspections, penalties, or new logs are triggered.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Locations with insufficient data should display a neutral or “unknown” state.
- Missing cargo or org data must not crash UI rendering.
- Indicator must not imply enforcement certainty or probability.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk of players misinterpreting indicators as guaranteed outcomes.
- Risk of future enforcement systems conflicting with early wording.
- If assumptions about available data prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0060-inspection-pressure-readonly/`
2) Write this job verbatim to `codex/runs/issue-0060-inspection-pressure-readonly/job.md`
3) Create `codex/runs/issue-0060-inspection-pressure-readonly/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0060-inspection-pressure-readonly`

Codex must write final results only to:
- `codex/runs/issue-0060-inspection-pressure-readonly/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] No new player actions were introduced
- [ ] No new log entries were added
- [ ] No UI-only interactions emit logs
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log volume and semantics remain unchanged
