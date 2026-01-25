# Feature Job

## Metadata (Required)
- Issue/Task ID: 0079
- Short Title: Level-1 Inspection Failure Escalates Customs Pressure
- Run Folder Name: issue-0079-level1-pressure-escalation
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Introduce pressure-only consequences for failed Level-1 customs inspections.  
When a Level-1 inspection fails, customs pressure increases deterministically for the relevant jurisdiction, with clear player-facing logs and no enforcement.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections never mutate cargo, credits, or freight documents.
- Inspections never block player actions.
- Randomness affects whether an inspection occurs, never its outcome or consequences.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No fines, holds, seizures, or travel blocking.
- No changes to inspection previews, inspection triggers, or inspection depth.

---

## Context
The inspection system currently performs deterministic Level-1 surface compliance checks at player-action boundaries (system entry, legal cargo sale, port departure).  
Inspection outcomes are logged but have no consequences beyond information disclosure.  
Customs pressure already exists as a read-only derived value and is surfaced to the player, but it does not yet respond to inspection outcomes.

This job introduces the first non-enforcement consequence: pressure escalation on failed inspections only.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).

- Add a centralized helper in GameState to apply deterministic customs pressure increases.
- Invoke this helper only when a Level-1 inspection result is FAIL.
- Clamp pressure changes to existing pressure bucket rules.
- Emit a separate, human-readable CUSTOMS log entry describing increased scrutiny.
- Ensure preview paths and successful inspections remain unaffected.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Customs.gd`

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

- `GameState.apply_customs_pressure_increase(jurisdiction_id: String, reason: String)` (new helper)

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Existing saves must continue to load without modification.
- Save/load verification requirements:
  - Verify pressure escalation persists correctly across save/load cycles if pressure is already persisted elsewhere.

---

## Determinism & Stability (If Applicable)
- Pressure increases must be deterministic and repeatable for identical inspection outcomes.
- Pressure changes must depend only on inspection failure and jurisdiction, not time or RNG.
- No new randomness, timers, or background processes may be introduced.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Failed Level-1 inspections increase customs pressure for the inspection jurisdiction.
- [ ] Passed inspections produce no pressure changes.
- [ ] Pressure escalation emits a separate CUSTOMS log entry.
- [ ] No player actions are blocked or denied.
- [ ] Inspection preview output remains unchanged.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Enter a system or port with elevated customs pressure and intentionally fail surface compliance.
2. Observe inspection result log.
3. Observe a subsequent CUSTOMS log indicating increased scrutiny.
4. Confirm customs pressure UI reflects the increase.
5. Repeat with a passing inspection and confirm no pressure change occurs.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Multiple failed inspections in succession should stack pressure increases deterministically.
- Missing or invalid jurisdiction identifiers must fail safely without crashing.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, or architectural concerns.

- Pressure escalation magnitude must remain conservative to avoid runaway difficulty.
- Ensure pressure mutation is centralized to avoid future duplication.
- If assumptions about pressure storage are incorrect, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0079-level1-pressure-escalation/`
2) Write this job verbatim to `codex/runs/issue-0079-level1-pressure-escalation/job.md`
3) Create `codex/runs/issue-0079-level1-pressure-escalation/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0079-level1-pressure-escalation`

Codex must write final results only to:
- `codex/runs/issue-0079-level1-pressure-escalation/results.md`

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
