# Feature Job

## Metadata (Required)
- **Issue/Task ID:** Issue-0036  
- **Short Title:** Inspection Consequences (Log Only)  
- **Run Folder Name:** issue-0036-feature-inspection-consequences-log-only  
- **Job Type:** feature  
- **Author (human):** Douglass Kyd  
- **Date:** 2026-01-19  

---

## Goal
When the player undergoes a customs inspection, the game should emit clear, human-readable log entries describing the inspection classification and the *recommended* consequences (fine/seizure/etc.), without applying any enforcement or mutating gameplay state beyond what the inspection already does today.

This makes inspections feel consequential while remaining consequence-free for the current feature cycle.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Customs inspection remains **read-only** with respect to enforcement (no fines, seizures, reputation, or legality effects).
- UI remains read-only; all state mutations continue to occur exclusively via `GameState`.
- Log entries are emitted **only** for explicit inspection actions or entry-triggered inspections.
- No per-frame, loop-driven, or duplicated logging is introduced.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No money changes, cargo removal, contract mutation, or document destruction as enforcement.
- No reputation, legality, escalation, or faction systems are introduced.
- No new UI panels, buttons, or layout changes.
- No persistence or save/load behavior is added.

---

## Context
Customs inspection (Issue-0028) is implemented as a read-only pipeline:

- `GameState.run_customs_inspection()` produces a structured report:
  - `classification: clean | suspicious | invalid`
  - `reasons: Array[String]`
  - document summary (authenticity, evidence counts)
  - `recommended_penalty` (placeholder data only)

Inspections may be triggered:
- Explicitly via Port ? Customs (CustomsInspectionPanel, read-only)
- Implicitly via entry customs checks (currently logging minimal info)

What is missing is **consistent, standardized log narration** that communicates inspection outcomes and *hypothetical* consequences to the player.

---

## Standard Log Message Format (Authoritative)

All inspection-related log entries must conform to the following structure:

CUSTOMS: <CLASSIFICATION> — <SUMMARY>. <RECOMMENDATION>


### Classification Tokens
- `CLEAN`
- `SUSPICIOUS`
- `INVALID`

### Message Rules
- `<SUMMARY>` must be concise and human-readable.
- When multiple reasons exist, only the **top reason** is included.
- `<RECOMMENDATION>` must be explicitly non-enforcing and conditional.

### Examples
- `CUSTOMS: CLEAN — No irregularities detected.`
- `CUSTOMS: SUSPICIOUS — Container metadata mismatch detected. Recommended fine: 2,500 credits.`
- `CUSTOMS: INVALID — Destroyed freight document detected. Recommended action: deny entry and seize cargo.`

This format is forward-compatible with future enforcement systems and intentionally avoids implying consequences are applied.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Centralize inspection-result logging in one authoritative location (preferably `GameState`).
- Map inspection classifications to standardized log message templates.
- Safely extract and summarize the top inspection reason, if present.
- Append recommended penalty information only if provided by the inspection report.
- Ensure each inspection event produces exactly one log entry.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Log.gd` *(only if a minimal helper is required)*

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
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

- [ ] Each customs inspection produces exactly one standardized log entry.
- [ ] Log entries include classification and summary; recommendation text appears only when applicable.
- [ ] No enforcement effects (fines, seizures, reputation changes) occur.
- [ ] Explicit Port-triggered inspections and implicit entry inspections produce consistent log formatting.
- [ ] No raw dictionaries or debug strings appear in the log.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. From Port, click **Customs** and verify a single inspection log entry appears using the standard format.
2. Force a suspicious or invalid inspection result and confirm:
   - Classification token is correct.
   - One clear reason is shown.
   - Recommendation text is present and non-enforcing.
3. Trigger an entry-based customs inspection and confirm identical log formatting and no duplication.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or empty `reasons` array must still produce a valid summary.
- Missing `recommended_penalty` must omit recommendation text cleanly.
- Long reason lists must be truncated to one summary reason.
- Repeated inspections must produce separate log entries without duplication.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Logging must not occur both in the inspection runner and the caller (avoid double-logging).
- Message wording must remain explicitly hypothetical to prevent player confusion.
- Future enforcement work may reuse these log messages; consistency matters.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0036-feature-inspection-consequences-log-only/`  
2) Write this job verbatim to `codex/runs/issue-0036-feature-inspection-consequences-log-only/job.md`  
3) Create `codex/runs/issue-0036-feature-inspection-consequences-log-only/results.md` if missing  
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0036-feature-inspection-consequences-log-only`

Codex must write final results only to:
- `codex/runs/issue-0036-feature-inspection-consequences-log-only/results.md`

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
