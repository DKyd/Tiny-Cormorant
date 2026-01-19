# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0042
- Short Title: Explicit Log Categories for Ship & Customs Actions
- Run Folder Name: issue-0042-feature-explicit-log-categories
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Ensure ship-related actions and customs inspections emit explicitly categorized log entries so the log panel renders consistent, intentional color coding without relying on inference.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Logging remains read-only with respect to game state.
- No gameplay logic, enforcement, or outcomes are changed.
- Log entries remain deterministic and capped.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Introduce new log messages or change existing log text.
- Expand log category taxonomy beyond SHIP and CUSTOMS.

---

## Context
The logging system now supports explicit categories and context metadata, and the LogPanel renders entries with category-based color coding. Currently, most log entries rely on conservative inference and therefore appear as OTHER. Ship actions (travel, docking, waiting) and customs inspections are known, stable actions that should be explicitly categorized at their emission sites.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).

- Identify existing Log.add_entry(...) calls related to ship actions and customs inspection.
- Update those call sites to pass an explicit category string ("SHIP" or "CUSTOMS").
- Leave all other log entries uncategorized (defaulting to OTHER).
- Do not alter log message text, ordering, or frequency.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/Bridge.gd`
- `scripts/Port.gd`

(If additional ship/customs log emitters are discovered, they must be explicitly justified in results.md.)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- `singletons/Log.gd`
- `scripts/ui/**`
- `scenes/ui/**`

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

- [ ] Ship-related actions (travel, docking, waiting) render as SHIP-colored entries in the log.
- [ ] Customs inspection log entries render as CUSTOMS-colored entries.
- [ ] No new log messages are introduced and existing message text remains unchanged.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a new game.
2. Perform ship actions (dock, travel, wait) and confirm log entries render in SHIP color.
3. Trigger a customs inspection and confirm the inspection log entry renders in CUSTOMS color.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- A ship action emits no category due to a missed call site (renders as OTHER).
- Multiple ship actions in sequence render consistently without flicker or duplication.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Over-expanding scope into contracts or economy categories is explicitly deferred.
- This job establishes a pattern for explicit categorization that future features should follow.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0042-feature-explicit-log-categories/`
2) Write this job verbatim to `codex/runs/issue-0042-feature-explicit-log-categories/job.md`
3) Create `codex/runs/issue-0042-feature-explicit-log-categories/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0042-feature-explicit-log-categories`

Codex must write final results only to:
- `codex/runs/issue-0042-feature-explicit-log-categories/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player ship actions emit SHIP-category log entries
- [ ] Customs inspection emits a CUSTOMS-category log entry
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages remain human-readable and unchanged
- [ ] `print()` usage is not introduced
- [ ] Log volume remains appropriate for a capped, recent-history log
