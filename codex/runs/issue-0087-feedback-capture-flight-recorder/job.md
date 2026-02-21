# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0087
- Short Title: Feedback Capture Flight Recorder (Snapshot + Log Tails)
- Run Folder Name: issue-0087-feedback-capture-flight-recorder
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Provide a reproducible “feedback capture” mechanism for playtesting: a single action produces a timestamped bundle on disk containing (1) a minimal game-state snapshot and (2) both player-facing and dev log tails, so that reported experiences can be reproduced and debugged.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Log history remains capped (no unbounded growth) and remains safe to refresh in UI.
- Gameplay determinism is unchanged: capture/export must not modify simulation state, RNG, inspection triggers, time ticks, or economy.
- Player-facing log remains readable and non-spammy; dev-only forensic details must remain hidden unless explicitly toggled.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Do not implement any network submission / telemetry / analytics or external reporting pipeline.
- Do not implement a polished “Give Feedback” UI flow (menus, modal forms, screenshots, attachments, UX polish).
- Do not alter customs/inspection/trade logic, probabilities, triggers, or outcomes.

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- `res://singletons/Log.gd` is the canonical in-memory log store with a cap (`MAX_LOG_ENTRIES = 300`). Each entry stores `text`, `category`, and captured context fields `tick/system_id/location_id`. A `message_added` signal prompts UI refresh. There is currently no dev-only vs player-only distinction per entry.
- `res://scripts/ui/LogPanel.gd` is a view over `Log`. It includes a “DevToggle” checkbox; currently the toggle controls whether a context prefix is displayed, but does not filter dev-only content.
- We need a standardized way to snapshot current state and log tails during UAT and future player testing, producing an on-disk artifact that can be attached to issues and used to reproduce the state and understand what the player saw versus what the engine decided.
- `res://scripts/MainGame.gd` is attached to the top-level runtime node and already participates in `_unhandled_input`, making it an appropriate host for a temporary capture hotkey without touching `scenes/MainGame.tscn`.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Extend `Log.gd` to support marking entries as dev-only and to export recent log tails in structured and text formats.
- Update `LogPanel.gd` so the dev toggle actually controls visibility of dev-only entries (dev OFF hides dev-only; dev ON shows all) while preserving current prefix behavior.
- Add a new singleton `FeedbackCapture.gd` that writes a timestamped folder under `user://feedback/` containing snapshot and log tail files.
- Add a minimal hotkey in `MainGame.gd` (F8) to invoke `FeedbackCapture.capture()` during playtests. Avoid modifying Project Settings/InputMap for this job.
- Ensure all file writes fail gracefully and do not crash gameplay; record failures as a single dev log entry.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Log.gd`
- `res://scripts/ui/LogPanel.gd`
- `res://scripts/MainGame.gd`

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

- `res://singletons/FeedbackCapture.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- `Log.add_entry(text: String, category: String = "", is_dev: bool = false) -> void` (adds optional `is_dev`)
- `Log.get_tail(max_entries: int, include_dev: bool) -> Array[Dictionary]` (new)
- `Log.format_tail_text(max_entries: int, include_dev: bool, include_prefix: bool) -> String` (new)
- `FeedbackCapture.capture(note: String = "", tags: Array[String] = []) -> String` (new; returns created folder path or "" on failure)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None (no savegame schema changes)
- Migration / backward-compat expectations:
  - Existing callers of `Log.add_entry(text, category)` must continue to work unchanged.
  - Existing uses of `Log.get_entry_*()` must continue to work; new fields in entry dictionaries must not break consumers.
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Snapshot/export outputs are derived deterministically from current in-memory state at time of capture.
- What inputs must remain stable?
  - Existing captured log context fields (`tick/system_id/location_id`) remain accurate and unchanged in meaning.
- What must not introduce randomness or time-based variance?
  - Capture must not alter RNG state or any simulation variables. (Timestamps may appear in exported filenames/metadata but must not affect gameplay logic.)

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Dev-only log entries can be created via `Log.add_entry("...", "OTHER", true)` and are hidden in `LogPanel` when dev toggle is OFF and visible when ON.
- [ ] Pressing F8 during gameplay creates a new folder under `user://feedback/<timestamp>/` containing:
      - `snapshot.json`
      - `player_log_tail.txt`
      - `dev_log_tail.txt`
      - `report.md`
- [ ] `player_log_tail.txt` excludes dev-only entries; `dev_log_tail.txt` includes them and includes contextual prefixes.
- [ ] Log entry cap (`MAX_LOG_ENTRIES`) still holds after spamming >300 entries; UI refresh remains stable.
- [ ] If feedback directory creation or file writes fail, gameplay does not crash; a single dev log entry is emitted indicating failure and `capture()` returns `""`.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Run the game and open the Log panel.
2. Trigger a normal gameplay log (travel, wait, buy/sell) and confirm it displays.
3. Inject a dev-only message (temporary test call or console call): `Log.add_entry("DEV ONLY TEST", "OTHER", true)`.
   - Confirm with DevToggle OFF: "DEV ONLY TEST" is NOT visible.
   - Confirm with DevToggle ON: "DEV ONLY TEST" IS visible (and prefixed with tick/sys/loc context).
4. Press F8 once.
5. Locate the new `user://feedback/<timestamp>/` directory via OS file explorer (or Godot user data folder) and confirm required files exist.
6. Open the tail files:
   - Confirm player tail does not include "DEV ONLY TEST".
   - Confirm dev tail does include "DEV ONLY TEST" and includes prefixes.
7. Stress test: add >350 log entries quickly (via an existing debug action if available) and confirm `Log.get_entry_count()` does not exceed 300 and UI remains responsive.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- `GameState` missing or not initialized: snapshot writes safe defaults (tick=-1, empty system/location) and capture still completes.
- Directory creation fails (permissions/path): `capture()` returns `""` and emits exactly one dev log entry describing the failure.
- Entries missing expected keys (legacy/empty dict): export helpers and UI skip gracefully without crashing.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- `LogPanel.gd` currently uses `Log.get_entry_text/category/context`; switching to reading `Log.get_entry(i)` for `is_dev` filtering must not change display ordering or coloring.
- Avoid adding any per-frame or spammy logging in the capture path; only one success log line at most (dev-only) is acceptable.
- F8 hotkey must not interfere with existing gameplay controls; it should consume the input only when triggered.
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