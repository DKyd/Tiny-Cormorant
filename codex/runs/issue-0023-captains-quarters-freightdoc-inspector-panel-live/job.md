# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0023
- Short Title: Captain’s Quarters FreightDoc Inspector Panel (Live)
- Run Folder Name: issue-0023-captains-quarters-freightdoc-inspector-panel-live
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Add a read-only inspector panel in Captain’s Quarters that displays details for the currently selected FreightDoc and updates live when that document changes (edit or destroy). This provides immediate player-facing visibility into FreightDoc state and modifier effects without adding enforcement, penalties, or new gameplay consequences.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations continue to occur via GameState APIs only.
- Views/spaces are changed only via `MainGame._show_view()` and TopBar navigation; no panel self-closes or manages lifecycle.
- FreightDoc edits and destruction remain source-gated (e.g., `source == "captains_quarters"`) and continue to emit immutable edit events.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add authenticity scoring, evidence flags, inspections, enforcement, fines, seizures, or reputation changes.
- Do not add save/load persistence or data migrations for any FreightDoc fields or UI state.
- Do not introduce new FreightDoc mutation paths or player actions.

---

## Context
Captain’s Quarters is a first-class navigable space (`scenes/CaptainsQuarters.tscn`) that embeds `scenes/ui/CaptainsQuartersPanel.tscn`. Panels are content-only and do not manage lifecycle or navigation.

FreightDocs can be modified or destroyed via GameState (`modify_freight_doc`, `destroy_freight_doc`), and runtime normalization ensures required runtime fields exist (`declared_quantity`, `container_meta`, `is_destroyed`, `edit_events`).

Currently, there is no dedicated UI to observe the *current* state of a selected FreightDoc while edits occur. This makes it difficult to validate modifier behavior or detect bugs during development. This job adds visibility only.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Add a read-only “Selected FreightDoc” inspector area to the Captain’s Quarters UI.
- Track the currently selected FreightDoc ID within the Captain’s Quarters panel.
- Render core FreightDoc fields (identity, status, declared quantity, container metadata, edit event summary).
- Add a GameState signal that fires when a FreightDoc changes.
- Refresh the inspector automatically when the selected FreightDoc emits a change event.
- Ensure all updates are event-driven (no per-frame polling).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`

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

- New GameState signal:  
  `signal freight_doc_changed(doc_id: String, change_kind: String)`

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Captain’s Quarters displays a “Selected FreightDoc” inspector panel showing details for the selected document.
- [ ] Selecting a different FreightDoc updates the inspector immediately and correctly.
- [ ] Modifying or destroying the selected FreightDoc updates the inspector automatically without reselecting or reopening the view.
- [ ] Inspector behavior remains read-only and introduces no new mutation paths.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and navigate to Captain’s Quarters via the TopBar.
2. Select a FreightDoc from the list and verify the inspector populates with correct data.
3. Modify declared quantity or container metadata for the selected doc and confirm the inspector updates immediately.
4. Destroy the selected FreightDoc and confirm the inspector reflects the destroyed state without errors.
5. Select another FreightDoc and confirm the inspector updates accordingly.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Selected FreightDoc becomes invalid or missing (e.g., destroyed and removed from list): inspector clears or shows a “no selection” state without crashing.
- FreightDoc fields missing or malformed in runtime data: inspector renders safely using normalized defaults.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, or architectural concerns.

- GameState signal connections must be managed carefully to avoid duplicate or dangling connections.
- Inspector updates must remain event-driven to avoid performance issues.
- UI must remain strictly observational; future refactors should not repurpose inspector logic for mutations.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0023-captains-quarters-freightdoc-inspector-panel-live/`
2) Write this job verbatim to `codex/runs/issue-0023-captains-quarters-freightdoc-inspector-panel-live/job.md`
3) Create `codex/runs/issue-0023-captains-quarters-freightdoc-inspector-panel-live/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0023-captains-quarters-freightdoc-inspector-panel-live`

Codex must write final results only to:
- `codex/runs/issue-0023-captains-quarters-freightdoc-inspector-panel-live/results.md`

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
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
