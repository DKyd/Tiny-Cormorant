# Feature Job

## Metadata (Required)
- Issue/Task ID: 0063
- Short Title: Organization Influence Inspector
- Run Folder Name: issue-0063-organization-influence-inspector
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-21

---

## Goal
Provide a developer-facing inspector that surfaces organization influence data for the current location.  
This feature improves observability and tuning confidence without adding simulation, persistence, or player-facing power.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Organization influence remains deterministic and read-only.
- No organization behavior, enforcement, or simulation is introduced.
- No player-facing gameplay effects or economic changes result from this feature.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add organization ticks, AI behavior, or persistence.
- Do not expose organization influence to players outside developer/debug contexts.

---

## Context
The Organizations epic currently includes deterministic, non-persistent influence values per location and read-only queries such as `GameState.get_location_effective_influences(location_id)`. Influence is surfaced minimally to players via high-level buckets (Trace / Present / Dominant) in the Port header.

What is missing is a developer-facing view that exposes raw influence weights, thresholds, and contributing context to aid debugging, tuning, and future design decisions. This job adds visibility only; it does not alter influence computation or usage.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only.

- Add a developer-facing inspector panel or toggleable view accessible in debug/dev contexts.
- Display raw organization influence weights for the current location.
- Display derived buckets (Trace / Present / Dominant) alongside raw values.
- Pull data exclusively from existing read-only GameState queries.
- Ensure the inspector has no side effects and emits no logs.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/ui/Port.gd`
- `scripts/ui/PortHeader.gd`
- `scripts/ui/OrgInfluenceInspector.gd`
- `scenes/ui/OrgInfluenceInspector.tscn`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes
- [ ] No

If Yes, list exact new file paths:

- `scripts/ui/OrgInfluenceInspector.gd`
- `scenes/ui/OrgInfluenceInspector.tscn`

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
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
- What inputs must remain stable?
- What must not introduce randomness or time-based variance?

- Influence values and buckets must remain fully deterministic.
- The inspector must reflect current GameState without modifying it.
- No randomness, ticking, or time-based variance may be introduced.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] A developer-facing inspector can be opened from the Port UI in debug/dev context.
- [ ] The inspector displays raw organization influence weights for the current location.
- [ ] No logs, state changes, or gameplay effects occur when using the inspector.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Run the game in debug/dev mode and dock at a location.
2. Open the Port view and activate the organization influence inspector.
3. Verify displayed influence values match deterministic expectations and do not change gameplay behavior.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Locations with no influence data available.
- Unknown or future organization IDs.
- Inspector opened when no location is currently selected.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Inspector accidentally becomes player-visible; ensure access is clearly gated.
- Risk: Accidental coupling to influence computation; inspector must remain read-only.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0063-organization-influence-inspector/`
2) Write this job verbatim to `codex/runs/issue-0063-organization-influence-inspector/job.md`
3) Create `codex/runs/issue-0063-organization-influence-inspector/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0063-organization-influence-inspector`

Codex must write final results only to:
- `codex/runs/issue-0063-organization-influence-inspector/results.md`

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
