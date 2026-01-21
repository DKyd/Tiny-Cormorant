# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0061
- Short Title: Organization Presence Display (Read-Only, Port Header)
- Run Folder Name: issue-0061-org-presence-display-readonly
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-22

---

## Goal
Surface a read-only summary of organization presence at the current location in the Port header, making organizational influence legible to the player without introducing simulation, enforcement, or persistence.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Organization influence remains deterministic and non-persistent.
- No organization actions, ticks, or simulations are introduced.
- UI surfaces may display influence but must not decide legality, access, or outcomes.
- Existing gameplay behavior (markets, customs, time, freight) remains unchanged.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No organization simulation, actions, or time-based behavior.
- No economy, market, or legality changes.
- No persistence or save/load schema changes.
- No reuse or resurrection of previously lost code outside this scoped job.

---

## Context
The game already computes deterministic organization influence per location via `GameState.get_location_effective_influences(location_id)`. However, prior work intended to surface this information (Issue-0058) did not land in the repository and must be reintroduced cleanly.

Currently, players have no direct visibility into which organizations are present at a location, despite influence already affecting access and narrative context.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only.

- Derive a read-only organization presence summary from existing influence data.
- Bucket influence weights into descriptive labels (e.g., Trace / Present / Dominant).
- Render the summary in the Port header as an informational line.
- Reuse existing GameState queries; do not introduce new simulation logic.
- Ensure the display fails gracefully when influence data is unavailable.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/Port.gd`
- `scripts/ui/*` (if required for presentation only)

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

- None

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
- Organization presence summaries must be derived deterministically from existing influence data.
- No randomness, ticking, or time-based variance may be introduced.
- Bucketing thresholds must be stable and purely descriptive.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Port header displays an organization presence summary when influence data exists.
- [ ] Locations with no influence data display a neutral or “none detected” message.
- [ ] Organization presence display is stable across reloads for the same location.
- [ ] No gameplay behavior changes occur as a result of this display.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save and visit multiple locations with differing influence profiles.
2. Open Port and observe the organization presence line in the header.
3. Reload the game and revisit the same locations; confirm stability.
4. Confirm no logs, access changes, or enforcement actions occur.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or empty influence data must not crash UI rendering.
- Unknown organization IDs must render with a safe fallback label.
- Extremely small influence weights must still bucket consistently.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk of wording implying authority rather than presence.
- Risk of future simulation systems diverging from early phrasing.
- If influence data assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0061-org-presence-display-readonly/`
2) Write this job verbatim to `codex/runs/issue-0061-org-presence-display-readonly/job.md`
3) Create `codex/runs/issue-0061-org-presence-display-readonly/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0061-org-presence-display-readonly`

Codex must write final results only to:
- `codex/runs/issue-0061-org-presence-display-readonly/results.md`

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
