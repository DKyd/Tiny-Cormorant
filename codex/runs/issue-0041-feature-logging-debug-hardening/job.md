# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0041
- Short Title: Logging & Debug Instrumentation Hardening (Phase 1)
- Run Folder Name: issue-0041-feature-logging-debug-hardening
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Improve the clarity, usefulness, and scalability of the in-game log as system complexity increases, by adding basic structure, visual formatting, and a developer-facing display toggle without changing gameplay behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The log remains read-only with respect to game state.
- Log entries are deterministic and order-preserving.
- No gameplay logic or enforcement behavior is introduced or modified.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Introduce save/load persistence or file-based logging.
- Add enforcement, analytics, telemetry, or gameplay consequences.

---

## Context
The game currently has a persistent, capped, player-facing log panel that survives view swaps and is used for major actions such as travel, waiting, and customs inspection. Log entries are human-readable but minimally structured and visually uniform. As markets, trading, tariffs, and ETA systems are added, debuggability and clarity need to scale without introducing noise or complexity.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).

- Add lightweight log categorization (e.g. SHIP/TRAVEL/WAIT, CUSTOMS, OTHER) suitable for display-only use.
- Introduce basic visual formatting in the log panel based on category (e.g. green for ship actions, orange for customs).
- Add a developer-mode checkbox above the log that toggles additional contextual display (tick, system/location identifiers) without changing what is logged.
- Widen the log panel by approximately 100 pixels to improve readability.
- Keep all formatting and dev-mode behavior strictly within the log rendering layer.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/ui/LogPanel.gd`
- `scenes/ui/LogPanel.tscn`
- `singletons/Log.gd`

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

- Optional additions to `Log.add_entry()` parameters to accept category metadata.
- No new public-facing systems or signals.

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

- [ ] Log panel width is increased by approximately 100 pixels without breaking layout.
- [ ] A checkbox labeled “Dev” appears above the log and toggles additional contextual display only.
- [ ] Ship-related log entries render in green; customs-related entries render in orange; all others render in default grey.
- [ ] Log history remains capped and does not grow unbounded.
- [ ] No gameplay behavior changes occur when dev mode is toggled.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and start a new session.
2. Perform ship actions (travel, wait) and observe log color and readability.
3. Trigger a customs inspection and verify customs log entries render distinctly.
4. Toggle the “Dev” checkbox and confirm additional contextual information appears without new log entries being created.
5. Play long enough to confirm old log entries roll off correctly.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Dev mode toggled rapidly or mid-session.
- Log panel resizing on different window sizes or resolutions.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Formatting must remain a presentation concern only; stored log data should remain clean and exportable.
- Category color choices are provisional and may be revisited once categories are formally codified.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0041-feature-logging-debug-hardening/`
2) Write this job verbatim to `codex/runs/issue-0041-feature-logging-debug-hardening/job.md`
3) Create `codex/runs/issue-0041-feature-logging-debug-hardening/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0041-feature-logging-debug-hardening`

Codex must write final results only to:
- `codex/runs/issue-0041-feature-logging-debug-hardening/results.md`

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
