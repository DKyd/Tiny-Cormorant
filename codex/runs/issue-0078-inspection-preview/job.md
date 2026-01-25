# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0078
- Short Title: Add read-only Customs inspection preview (Port UI)
- Run Folder Name: issue-0078-inspection-preview
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Add a **read-only inspection preview** surfaced in the Port view near existing Customs pressure info, so players can see (1) qualitative likelihood of a Customs check and (2) the maximum possible inspection depth for the current jurisdiction. This preview must not trigger inspections, must not roll RNG, and must not mutate state.

---

## Invariants (Must Hold After This Job)
- Inspections remain deterministic and continue to use `GameState.roll_customs_inspection(...)` when they run; **preview does not roll**.
- Preview is **read-only**: it must not mutate cargo, credits, docs, pressure, reputation, or time tick.
- Preview remains explainable and stable: given the same inputs, it returns the same output and UI text.

---

## Non-Goals
- Do not activate any new inspections or triggers (no new calls to `roll_customs_inspection`, `run_customs_inspection`, or `Customs.run_*_check`).
- No enforcement: no fines, holds, seizures, delays, travel blocking, cargo denial, or document destruction.
- No deep audit (Level 2+) logic; preview is informational only and based on existing Phase 1 primitives.

---

## Context
Phase 1 inspections are now wired for entry, legal sale, and port departure, and logs are categorized correctly. Customs pressure is already derived deterministically and surfaced in Port UI. What is missing is a **player-facing preview** that explains Customs “risk” before any consequences exist. The roadmap calls for a read-only `GameState.get_inspection_preview(context) -> Dictionary` helper and UI surfacing near Customs pressure.

---

## Proposed Approach
- Add `GameState.get_inspection_preview(context: Dictionary) -> Dictionary` that computes:
  - a qualitative likelihood label derived from the location’s pressure bucket (and/or the mapped chance value), without rolling RNG
  - a maximum inspection depth value that is derived from existing jurisdiction/pressure data (fallback to Level 1 if depth mapping is not yet implemented)
  - a short list of contributing reasons (pressure bucket, jurisdiction selection, and basic document surface state if already available)
- Add a small read-only UI block in the Port header near the Customs pressure line to display preview info.
- Ensure preview chooses the same “jurisdiction location” rule used for system entry when the player is not docked (highest-pressure location in system, lexicographic tie-break), but does not trigger any checks.
- Keep output stable and human-readable; no per-frame recalculation spam (compute on port refresh / location change).
- Add/confirm log behavior: preview must not add log entries.

---

## Files: Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`
- `res://scripts/Port.gd`
- `res://scenes/Port.tscn`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:
- (None)

---

## Public API Changes
- Add: `GameState.get_inspection_preview(context: Dictionary) -> Dictionary`

---

## Data Model & Persistence
- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- Preview results must be deterministic and stable for the same context inputs (system_id, location_id, docked state, and current computed pressure bucket).
- Preview must not call RNG, must not depend on global RNG state, and must not depend on real time.
- Preview must not advance ticks or mutate gameplay state.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Port view shows a read-only “Inspection preview” (or equivalent label) near Customs pressure, including qualitative likelihood and max depth.
- [ ] Preview does not trigger any inspections and does not call deterministic roll logic (no new inspection logs; no calls to `roll_customs_inspection` from preview).
- [ ] Preview output changes appropriately when moving between locations/systems with different customs pressure buckets (e.g., Low vs High) and when docked vs not docked (entry-jurisdiction selection rule applied for not-docked context).

---

## Manual Test Plan
1. Start game, dock at a port with known Customs pressure bucket (Low/Elevated/High visible in header).
2. Observe the new Inspection preview line(s) near Customs pressure:
   - verify it displays qualitative likelihood and max depth
   - verify no log entries are added simply by viewing the UI
3. Travel to a different system/location with a different pressure bucket and open Port again:
   - verify preview updates to match the new bucket
4. Undock (so `current_location_id == ""`) and open Port-related UI state if applicable (or use whichever view can show the header/context):
   - verify preview uses the system-level jurisdiction selection rule (highest-pressure location) rather than an empty location.

---

## Edge Cases / Failure Modes
- Missing/invalid system_id or location_id in context: preview returns safe defaults (e.g., likelihood “Unknown”, max depth 1, reasons indicating missing context) and UI does not crash.
- Player not docked (`current_location_id == ""`): preview must still be stable and should use deterministic jurisdiction selection (highest-pressure location).
- Unknown pressure bucket values: preview falls back to “Elevated” semantics (or a defined default) without errors.

---

## Risks / Notes
- Port UI layout risk: avoid breaking existing header spacing; keep preview compact and read-only.
- Avoid per-frame recompute: preview should update on location/system change or Port refresh, not in `_process`.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory) ?? NEW
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
- [x] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
