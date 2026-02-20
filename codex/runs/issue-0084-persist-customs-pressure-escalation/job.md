# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0084
- Short Title: Persist runtime Customs pressure escalation from Level-2 INVALID (save/load continuity)
- Run Folder Name: issue-0084-persist-customs-pressure-escalation
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-20

---

## Goal
Make Level-2 INVALID Customs outcomes have continuity across save/load by persisting the resulting pressure escalation deltas.  
On reload, the player should see the same increased scrutiny state that existed before saving, without introducing new enforcement or changing any inspection/audit semantics.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level-2 audits must never mutate cargo, credits, or documents; they must never block movement or trade.
- Level-2 classification semantics and invariant logic remain unchanged (Phase 4.0 lock).
- Pressure escalation remains a *pressure-only* consequence: no enforcement, no fines, no holds, no seizures, no movement/trade blocking.
- Determinism: for the same world state + saved pressure deltas, inspection preview and execution results remain deterministic and explainable.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add enforcement mechanics (holds, seizures, fines), reputation effects, or any new gameplay consequences beyond pressure continuity.
- Do not introduce decay, timers, probabilistic escalation, or any new logic for *how* escalation is computed; only persist/restore the existing deltas.
- Do not change Level-1/Level-2 inspection gating, preview authority, max_depth clamping, or audit invariants.

---

## Context
Currently, Level-2 INVALID results increment a government influence delta / scrutiny effect at the location (runtime-only), and this resets on reload by design.  
With Phase 4.0 locked and Level-2 log visibility shipped, the next safe fast-lane step is to persist the already-existing escalation deltas so scrutiny feels continuous and the player can reason about consequences over time.  
This job should store only the minimal state necessary to reproduce the current “increased scrutiny” pressure effect after loading.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Identify the in-memory structure(s) holding the runtime-only pressure escalation delta(s) (government influence delta, scrutiny delta, or equivalent).
- Add a minimal saved representation for these deltas keyed by a stable identifier (likely `location_id`), and include it in the existing save payload.
- On load, restore the deltas exactly (no recomputation, no decay, no normalization beyond basic validation).
- Keep backward compatibility: missing fields in older saves must load cleanly and behave like current runtime-only reset behavior.
- Add bounded logging for restore events (single log line on load if non-empty), avoiding spam.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`
- `res://singletons/SaveLoad.gd` (or the existing save/load script in this repo; if different, update whitelist accordingly before coding)

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

- Prefer “None”.
- If absolutely required, any new methods must be private/internal (underscore-prefixed) or strictly within the save/load boundary and not expand gameplay-facing APIs.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - Add a saved field for Customs pressure escalation deltas (exact name TBD, but must be namespaced clearly, e.g. `customs_pressure_deltas_by_location`).
  - Representation: Dictionary keyed by `location_id` ? numeric delta (or a small Dictionary if multiple deltas must be persisted), matching the existing runtime concept.
- Migration / backward-compat expectations:
  - Older saves lacking the new field must load without error and behave as “no persisted deltas” (i.e., baseline behavior).
  - Unknown keys or invalid values must be ignored safely (with optional dev log), not crash.
- Save/load verification requirements:
  - Verify that after a Level-2 INVALID causes escalation, saving and reloading preserves the same inspection preview pressure bucket outcomes for the same location/system (where applicable).
  - Verify that saving before any escalation and reloading does not introduce any new deltas.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Persisted deltas must round-trip exactly; no floating drift, no recomputation differences.
  - Inspection preview results should match pre-save results given identical location + deltas.
- What inputs must remain stable?
  - Stable key: `location_id` (or the same identifier used by current delta storage).
  - Existing pressure computation should consume the restored delta exactly as it did at runtime.
- What must not introduce randomness or time-based variance?
  - No timers/decay, no new RNG, no “on-load recalculation” behaviors.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] After triggering a Level-2 INVALID that escalates scrutiny at a location, saving and reloading preserves the escalation effect (inspection preview pressure bucket / max depth behavior matches pre-save behavior at the same jurisdiction).
- [ ] Loading an older save (or a save with the new field missing) results in baseline behavior (no persisted deltas) without errors.
- [ ] Save/load round-trip does not change audit semantics: Level-2 findings/classifications remain unchanged for the same documents; only pressure continuity is affected.
- [ ] No new enforcement outcomes are introduced and no player actions are blocked due to persistence.
- [ ] Logging on load is bounded (at most one concise log entry when deltas are restored; none when empty).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start/load a game, get into a High-pressure jurisdiction where Level-2 can run, and force a Level-2 INVALID (known broken doc chain). Confirm log indicates increased scrutiny / escalation.
2. Note the inspection preview output (pressure bucket + max depth) for the same jurisdiction after escalation.
3. Save the game, quit to menu (or restart), reload the save.
4. Re-check inspection preview for the same jurisdiction: it should match the post-escalation preview from step 2 (continuity preserved).
5. Load a save made *before* any escalations (or delete the new field manually if you have a test save): verify no errors and baseline behavior.
6. Confirm no new holds/fines/seizures exist and trading/movement still proceeds normally.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Save file contains invalid delta values (non-numeric / negative / extremely large): clamp or ignore safely (must be deterministic and documented in results).
- Location IDs in save that no longer exist in the current galaxy seed/session: ignore safely.
- Multiple escalations at different locations: all must round-trip correctly without log spam.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: accidentally persisting derived/computed pressure instead of deltas, which would freeze outcomes incorrectly. Persist only the minimal delta inputs.
- Risk: save/load code path variance; keep migrations defensive and avoid hard failures.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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