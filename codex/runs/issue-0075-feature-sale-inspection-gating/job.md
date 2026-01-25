# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0075
- Short Title: Gate legal sale customs inspections behind deterministic chance
- Run Folder Name: issue-0075-feature-sale-inspection-gating
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Ensure that customs inspections triggered by **legal cargo sale** only occur when a deterministic, pressure-driven inspection attempt succeeds. Selling cargo should not always trigger an inspection; instead, the game should perform a seeded roll (deterministic) that decides whether an inspection occurs.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- Randomness affects **whether** a check occurs, never inspection outcomes or classification logic.
- Inspection attempts remain deterministic and reproducible for the same `(system_id, location_id, action, time_tick)` inputs.
- Customs inspections do not mutate cargo, credits, or freight documents.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add fines, holds, seizures, travel denial, or any enforcement outcome.
- Do not change inspection classification logic, evidence rules, or document validation rules.
- Do not introduce new Port Authority logic or simulation.
- Do not change market pricing, sell/buy calculations, or cargo accounting behavior.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- `GameState.run_customs_inspection(context)` exists and performs Level 1 surface compliance/evidence evaluation, emits logs, and returns an explainable report.
- `GameState.get_customs_pressure_bucket(location_id)` exists and maps derived pressure to `Low/Elevated/High`.
- `GameState.roll_customs_inspection(system_id, location_id, action, chance)` exists and performs deterministic seeded roll keyed by `(system_id, location_id, action, time_tick)`.
- `Customs.run_entry_check(system_id, location_id="")` exists and uses pressure bucket + deterministic roll to decide whether to run `GameState.run_customs_inspection()` for `ENTRY_CLEARANCE`.
- Current legal sale flow (`GameState.sell_manifest_goods(...)`) runs `run_customs_inspection(...)` whenever `market_kind == MARKET_KIND_LEGAL`, which is over-eager and does not apply frequency gating.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a dedicated customs helper for legal sale checks (or extend an existing Customs helper) that mirrors the entry-check pattern: pressure bucket ? chance ? deterministic roll ? optionally run inspection.
- Update the legal sale path to invoke the helper instead of always calling `GameState.run_customs_inspection(...)`.
- Ensure the inspection context uses `action = "SELL_CARGO_LEGAL"` and uses the actual `system_id` and `location_id` passed to the sale.
- Keep logs human-readable and avoid extra spam; no logs should be emitted when no inspection occurs (unless already present elsewhere).

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

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- Add: `Customs.run_sale_check(system_id: String, location_id: String) -> void` (new helper used by legal sale flow)
- None (no other public API changes)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - Not required (no data model changes)

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Whether a legal sale inspection occurs must be deterministic.
- What inputs must remain stable?
  - `(system_id, location_id, action="SELL_CARGO_LEGAL", time_tick)` and the pressure bucket ? chance mapping.
- What must not introduce randomness or time-based variance?
  - Must not use `randf()` or global RNG state; must not seed from wall-clock time.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Selling cargo legally does **not** always trigger an inspection; inspections occur only when a deterministic roll passes.
- [ ] The legal sale inspection attempt uses pressure bucket chance (`Low/Elevated/High`) and `GameState.roll_customs_inspection(...)` with `action = "SELL_CARGO_LEGAL"`.
- [ ] When an inspection occurs, `GameState.run_customs_inspection(...)` is called with the correct `system_id`, `location_id`, and action; when it does not occur, no inspection report is generated and no inspection-completed signal is emitted.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a game, dock at a location with a market, and acquire cargo + source documents (purchase order or contract).
2. Perform multiple legal sales of the same commodity (same location) across multiple ticks (use Wait / travel to advance time).
3. Observe that some sales do not produce a customs inspection log/report, while others do; verify that when an inspection occurs it references `SELL_CARGO_LEGAL` behavior and returns a normal report.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Selling at an invalid/empty `system_id` or `location_id` must not crash; the sale should follow existing error handling and inspections should not run.
- If chance is clamped to `0.0` or `1.0`, behavior must be predictable (never/always inspect) while remaining deterministic.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Duplicating entry-check logic; keep helper small and consistent with `Customs.run_entry_check`.
- Risk: Accidentally changing inspection classification or document validation; this job must only gate *whether* inspection is invoked.
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
