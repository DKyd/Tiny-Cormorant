# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0058
- Short Title: Organization Presence as Location Traits (Read-Only)
- Run Folder Name: issue-0058-org-presence-readonly
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-21

---

## Goal
Expose which organizations are present at a location in a read-only, descriptive way, making organization influence legible to the player without introducing simulation, persistence, or authority changes.

---

## Invariants (Must Hold After This Job)
- Organization influence remains deterministic, non-persistent, and non-simulated.
- No organization performs actions or changes state over time.
- UI surfaces may display organization presence but must not decide legality or access.
- All authority continues to flow through existing GameState queries.

---

## Non-Goals
- No organization actions, ticks, or simulations.
- No changes to economy, markets, legality, pricing, or persistence.
- No new influence logic or mutation of existing influence data.

---

## Context
Locations already have deterministic organization influence data introduced in Issue-0056, and black market access is gated via `GameState.location_has_black_market(location_id)` as of Issue-0057.  
Currently, this influence is not visible to the player except indirectly through access gating. There is no read-only surface that communicates which organizations are present or dominant at a location.

---

## Proposed Approach
- Derive a lightweight, read-only view of organization presence from existing influence data.
- Present organization presence in a descriptive, non-numeric or rounded form.
- Surface this information in an existing location-related UI context.
- Avoid introducing new panels, navigation paths, or authority flows.
- Ensure the feature is optional and fails gracefully when influence data is absent.

---

## Files: Allowed to Modify (Whitelist)
- `scripts/Port.gd`
- `scripts/ui/*`

Codex must restate this whitelist verbatim before making any code changes.

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
None.

---

## Data Model & Persistence
- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not applicable
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- Organization presence must be derived deterministically from existing influence logic.
- No randomness or time-based variance may be introduced.
- Display output must remain stable for a given world seed and location.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Locations display a read-only summary of organization presence.
- [ ] No new simulation, persistence, or economic behavior is introduced.
- [ ] Removing or disabling the UI surface does not affect gameplay logic.
- [ ] Existing black market gating behavior remains unchanged.

---

## Manual Test Plan
1. Load a save or start a new game with known locations.
2. Visit multiple locations and inspect the organization presence display.
3. Confirm that locations with different influence profiles show different summaries.
4. Verify that no new logs, market changes, or access changes occur.

---

## Edge Cases / Failure Modes
- Locations with no detectable influence should display a neutral or empty state.
- Missing or malformed influence data must not crash or block UI rendering.

---

## Risks / Notes
- Risk of accidentally leaking raw numeric influence values into UI.
- Risk of scope creep into simulation or legality logic.
- If assumptions about influence availability are incorrect, Codex must stop and report.

---

## Governance & Review Gates (Mandatory)
- Phase 0 Preflight must confirm AGENTS.md reflects current enforcement rules.
- Codex must STOP after scaffolding and await approval before implementation.
- Full diff review is required prior to writing results.md.
- Any scope or whitelist violation requires abort and report.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0058-org-presence-readonly/`
2) Write this job verbatim to `codex/runs/issue-0058-org-presence-readonly/job.md`
3) Create `codex/runs/issue-0058-org-presence-readonly/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0058-org-presence-readonly`

Codex must write final results only to:
- `codex/runs/issue-0058-org-presence-readonly/results.md`

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
- [ ] Log volume and semantics remain unchanged
