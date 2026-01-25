# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0081
- Short Title: Deterministic Level-2 Depth Gating via Customs Pressure
- Run Folder Name: issue-0081-deterministic-level-2-depth-gating-via-customs-pressure
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Deterministically expose Level-2 Customs audits to players by mapping existing customs pressure to a maximum inspection depth, surfaced through the inspection preview and consumed by live inspections.

This enables Level-2 audits in high-pressure jurisdictions without introducing enforcement, randomness, or hidden behavior.

---

## Invariants (Must Hold After This Job)

- Inspection depth is determined **only** by existing, deterministic world state (customs pressure + security), never by RNG.
- Inspection previews and live inspections must agree on `max_depth` for the same context.
- No inspection outcome mutates cargo, credits, or freight documents.

---

## Non-Goals

- Do NOT add new inspection levels, audit rules, or evidence checks.
- Do NOT introduce fines, seizures, holds, denials, or any enforcement mechanics.

---

## Context

Level-2 Customs audits (document chain coherence) are implemented and gated behind a `max_depth` value supplied to `run_customs_inspection()`.

Currently:
- `get_inspection_preview()` always reports `max_depth = 1`
- Customs callers pass preview depth through correctly
- Result: Level-2 audits never occur in normal gameplay

Customs pressure already exists, is deterministic, and is surfaced to players in the UI.

What is missing is a deterministic mapping from pressure (and/or security) to allowable inspection depth.

---

## Proposed Approach

- Extend `GameState.get_inspection_preview()` to compute `max_depth` based on:
  - customs pressure bucket
  - (optionally) system security level
- Return `max_depth = 2` only when conditions clearly justify deeper scrutiny.
- Add an explicit human-readable reason when Level-2 is possible.
- Leave all inspection execution logic unchanged.

---

## Files: Allowed to Modify (Whitelist)

- `res://singletons/GameState.gd`

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

- Modified behavior of:
  - `GameState.get_inspection_preview(context)`

No new public methods or signals are added.

---

## Data Model & Persistence

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Existing saves behave identically except where Level-2 is newly permitted.
- Save/load verification requirements:
  - None

---

## Determinism & Stability

- `max_depth` must be fully deterministic for a given:
  - system
  - location
  - pressure state
- No randomness, time-based variance, or mutable counters may influence depth.
- Preview and inspection must derive depth from identical logic.

---

## Acceptance Criteria

- [ ] Inspection preview reports `max_depth = 2` in clearly high-pressure contexts.
- [ ] Inspection preview reports `max_depth = 1` in low and elevated pressure contexts.
- [ ] Live Customs inspections consume the previewed depth without divergence.

---

## Manual Test Plan

1. Dock at a low-pressure location; open the Port UI and confirm preview shows max depth 1.
2. Increase customs pressure through repeated invalid inspections; confirm preview updates to max depth 2 when threshold is crossed.
3. Trigger a Customs inspection in a max-depth-2 context and confirm Level-2 audit runs and logs.

---

## Edge Cases / Failure Modes

- Missing or invalid preview context must fail closed to `max_depth = 1`.
- Pressure values at exact bucket boundaries must map consistently.

---

## Risks / Notes

- Over-permissive depth gating could expose Level-2 too early if thresholds are poorly chosen.
- UI copy must remain explainable and non-threatening.
- If assumptions about pressure semantics are incorrect, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)

- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0081-level2-depth-gating/`
2) Write this job verbatim to `codex/runs/issue-0081-level2-depth-gating/job.md`
3) Create `codex/runs/issue-0081-level2-depth-gating/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0081-level2-depth-gating`

Codex must write final results only to:
- `codex/runs/issue-0081-level2-depth-gating/results.md`

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
