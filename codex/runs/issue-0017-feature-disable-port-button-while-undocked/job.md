# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0017
- Short Title: Disable Port button while undocked
- Run Folder Name: issue-0017-feature-disable-port-button-while-undocked
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Goal
When the player is not docked at a location that provides port access, the Port button must be visibly disabled and non-interactable.
When the player is docked at a valid location with port access, the button must be enabled and behave exactly as it does today.

---

## Non-Goals
- This job must not change docking rules, access rules, or travel logic.
- This job must not add or remove ports, locations, or permissions.
- This job must not introduce new gameplay states or timers.
- This job must not hide the Port button; it must remain visible.
- This job must not emit log entries for UI-only state changes.

---

## Context
The Bridge UI currently exposes a Port button that is always selectable, even when the player is undocked or otherwise lacks access to a port.
Game state already tracks whether the player is docked and which location they occupy.
This feature aligns the UI affordance with existing state without altering underlying mechanics, maintaining the rule that UI is read-only with respect to game state.

---

## Proposed Approach
- Read existing authoritative state to determine whether port access is available.
- Update the Port button’s enabled/disabled state based on that state.
- Ensure the button becomes enabled immediately upon docking at a valid port.
- Ensure the button becomes disabled immediately upon undocking or traveling.
- Do not add new state or duplicate access logic in the UI.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- scripts/Bridge.gd
- (If required) the Bridge scene script that owns the Port button control

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- data/**
- scenes/MainGame.tscn

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Public API Changes
None.

---

## Acceptance Criteria (Must Be Testable)
- [ ] When the player is not docked, the Port button is disabled and cannot be clicked.
- [ ] When the player is docked at a location with port access, the Port button is enabled and clickable.
- [ ] Enabling/disabling the button does not generate log entries.
- [ ] Existing Port button behavior is unchanged when enabled.

---

## Manual Test Plan
1. Launch the game and start undocked or travel to an undocked state.
2. Open the Bridge and verify the Port button is visible but disabled.
3. Dock at a location that provides port access.
4. Verify the Port button becomes enabled immediately.
5. Click the Port button and confirm existing behavior is unchanged.
6. Undock or travel away and confirm the button disables again.

---

## Edge Cases / Failure Modes
- Rapid dock/undock transitions must not leave the button in a stale state.
- Loading a save while undocked must correctly initialize the button as disabled.
- Locations without port access must not enable the button even if docked.

---

## Risks / Notes
- The UI must rely exclusively on authoritative game state to avoid divergence.
- Care must be taken not to duplicate or re-encode access rules in the UI.
- The button’s disabled visual state should remain consistent with existing UI theming.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create codex/runs/issue-0017-feature-disable-port-button-while-undocked/
2) Write this job verbatim to codex/runs/issue-0017-feature-disable-port-button-while-undocked/job.md
3) Create codex/runs/issue-0017-feature-disable-port-button-while-undocked/results.md if missing
4) Write codex/runs/ACTIVE_RUN.txt = issue-0017-feature-disable-port-button-while-undocked

Codex must write final results only to:
- codex/runs/issue-0017-feature-disable-port-button-while-undocked/results.md

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
- [ ] print() usage is debug-only or removed in favor of Log.add_entry()
- [ ] Log volume feels appropriate for a capped, recent-history log
