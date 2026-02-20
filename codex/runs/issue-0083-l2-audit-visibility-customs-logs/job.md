# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0083
- Short Title: Level-2 audit visibility in Customs logs (codes, ordering, top-N, verbosity)
- Run Folder Name: issue-0083-l2-audit-visibility-customs-logs
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-20

---

## Goal
Make Level-2 Customs audits legible and debuggable by surfacing invariant codes and a deterministic summary in Customs-related log output.  
This job is presentation-only: it must not change audit semantics, findings, classification, or pressure escalation rules.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level-2 audits must never mutate cargo, credits, or documents; they must never block movement or trade.
- Level-2 classification semantics remain unchanged: any INVALID ? INVALID; else any SUSPICIOUS ? SUSPICIOUS; else CLEAN; result.ok iff CLEAN.
- Level-2 invariant list, codes, severities, and oversell semantics remain unchanged as locked in `issue-0082.../results.md`.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add, remove, rename, or change any Level-2 invariant code, severity, or message semantics.
- Do not change inspection gating, max_depth logic, preview authority, or any pressure escalation behavior.
- Do not introduce new UI panels or new inspection history UI (logs only).

---

## Context
Level-2 audits exist and produce structured findings with stable codes and severities, but the player/dev-facing logs do not currently surface the invariant codes and may not present findings in a deterministically readable form.  
We want Customs log output to show the Level-2 outcome (CLEAN/SUSPICIOUS/INVALID) plus the top-N invariant codes (and short reasons) in deterministic order, so audits can be understood without digging into internal structures.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a single formatting path for Level-2 audit reporting that emits: classification + (optional) ordered findings.
- Ensure deterministic ordering of findings for display (primary: severity, secondary: invariant code, tertiary: stable message).
- Limit output to top N findings (constant), with a “+X more” suffix when truncated.
- Add an opt-in verbosity toggle (dev-facing) to show structured data payloads; default is off.
- Keep logging volume capped and human-readable; no per-frame spam.

---

## Subtasks / Checkpoints (Internal, Still One Job) ?? NEW
Break the job into 4–8 concrete deliverables.  
Each checkpoint must remain within scope and respect invariants/non-goals.

1. Identify the existing log sites for Customs inspections (sell, depart, entry) and where Level-2 results are currently summarized.
2. Implement deterministic ordering for displayed findings (without changing underlying accumulation/classification).
3. Add top-N truncation with deterministic “more” count.
4. Add invariant codes to the displayed lines (e.g., `L2-12`) and include a short reason string.
5. Add optional verbosity flag to include structured data in logs (dev-only, default off).
6. Update/extend manual test plan to validate exact ordering and truncation.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`
- `res://singletons/GameState.gd`
- `res://singletons/Log.gd` (only if required for formatting helpers; avoid if possible)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- Any `codex/runs/issue-0082-*/results.md` content (Phase 4.0 lockfile)
- Any document schema/resource files (if present)

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

- None (preferred). If a helper is added, it must be private/internal (underscore-prefixed) and not expand the public surface.

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
  - Display ordering of findings must be deterministic for the same audit result.
  - Truncation behavior and “+X more” count must be deterministic.
- What inputs must remain stable?
  - Existing Level-2 audit result structures (codes, severities, messages, data) must be consumed without mutation.
- What must not introduce randomness or time-based variance?
  - No use of RNG, time, or unordered iteration for display ordering.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When a Level-2 audit runs, Customs logs include the audit classification (CLEAN/SUSPICIOUS/INVALID) and, if not CLEAN, include invariant codes for the top-N findings.
- [ ] Findings are displayed in deterministic order: INVALID before SUSPICIOUS; within same severity, sorted by invariant code ascending; stable tie-breaker by message string.
- [ ] If findings exceed N, log output includes a deterministic “+X more” suffix and does not spam additional lines beyond the chosen format.
- [ ] Default behavior is human-readable (no raw structured payloads). Verbose mode (if implemented) is opt-in and clearly labeled dev output.
- [ ] No changes to audit semantics: same inputs produce same classification and same set of findings as before.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save (or start) where Level-2 max_depth can be 2 (High pressure) and perform an action that triggers Customs inspection (e.g., sell cargo) until a Level-2 audit runs.
2. Force/arrange a known INVALID scenario (e.g., destroyed bill of sale or missing source doc) and repeat the trigger.
3. Verify the log includes: classification + invariant code(s) like `L2-0X` and that INVALID findings appear before any suspicious ones.
4. Create a scenario producing >N findings (if possible) and verify truncation with “+X more”.
5. If verbose mode exists, enable it and verify structured data appears only then and is clearly marked.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Audit returns CLEAN (no findings): logs should remain minimal and not add noise beyond classification (or may omit details entirely).
- Findings contain structured data dictionaries: must not print huge blobs by default; verbose mode only.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: accidental semantic changes if ordering logic mutates the findings list in-place; must sort a copy for display only.
- Risk: log spam if each finding is logged as its own entry; prefer a compact single-entry summary (or tight bounded lines).
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