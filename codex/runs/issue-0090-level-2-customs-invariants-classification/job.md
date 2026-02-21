# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0090
- Short Title: Implement Level-2 Customs Invariants and Classification (CLEAN / SUSPICIOUS / INVALID)
- Run Folder Name: issue-0090-level-2-customs-invariants-classification
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Implement **Level-2 Customs audits** that evaluate **cross-document chain coherence** using minimal invariants and produce an explainable **CLEAN / SUSPICIOUS / INVALID** classification at eligible inspection triggers.  
Level-2 outcomes must be **logged** and included in inspection reports, but must **not** block actions or mutate cargo, credits, or freight documents.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- **No enforcement / no mutation at Level 2:** No Level-2 outcome may mutate cargo, credits, or freight docs; no blocking of trade or movement.
- **Deterministic detection:** Invariant evaluation must be deterministic given doc/event state; no RNG usage inside detection logic.
- **Action-boundary only:** Level-2 audits run only through existing inspection triggers (no background checks, no per-frame evaluation).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Implement Level 3 reconciliation (mass/capacity) or Level 4 physical inspections (seizures, fines, holds, denial).
- Add new UI panels or change market flow; logs/report fields only.

---

## Context
`GameState.run_level2_customs_audit(context)` exists and currently prepares Level-2 reporting structures but lacks the minimal invariant checks and robust classification semantics defined in the North Star.  
`GameState.get_freightdoc_chain_snapshot()` provides docs-by-id and tick for deterministic as-of evaluation.  
What is missing: the actual **cross-document invariant checks** (oversell, destroyed/missing source, temporal contradictions), consistent **reason/finding objects** (including message), and final **CLEAN/SUSPICIOUS/INVALID** classification mapping.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Implement the minimal Level-2 invariant checks within `GameState.run_level2_customs_audit()`:
  - **Quantity conservation / oversell** (aggregate sold > aggregate acquired for the documented chain ? INVALID)
  - **Destroyed or missing source references** ? INVALID
  - **Temporal contradictions** (sale before acquisition for referenced chain) ? INVALID
- Add **SUSPICIOUS** heuristics only where data is incomplete/ambiguous (e.g., missing provenance fields, unknown source availability) without escalating to INVALID unless logically impossible.
- Ensure Level-2 produces a structured report: `classification`, `reasons` (with severity + message), and `findings` (optional) suitable for log snippets.
- Log exactly one human-readable Level-2 summary per qualifying inspection trigger (no spam).
- Keep changes strictly within whitelist; stop and report if required data is unavailable rather than inventing new persistence.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd` *(only if required to pass/format Level-2 context or logs; otherwise leave untouched)*

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

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None (preferred). If unavoidable, list exact new helper methods added to `GameState.gd` and keep them private/conventional (e.g., `_level2_*`).

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - Existing saves must load without migration and without null dereferences in Level-2 audit.
- Save/load verification requirements:
  - Load an existing save (if available) and confirm Level-2 audit runs without errors and produces logs.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Level-2 classification and reasons given the same doc snapshot.
- What inputs must remain stable?
  - `context.docs` is docs-by-id Dictionary (snapshot) and must not be mutated.
  - `context.tick/system_id/location_id/action` are treated as read-only inputs for logging and deterministic reporting.
- What must not introduce randomness or time-based variance?
  - No RNG calls in Level-2 evaluation; no wall-clock time.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Level-2 audit returns `classification` ? {`clean`, `suspicious`, `invalid`} and includes at least one reason with `severity` + `message` when not `clean`.
- [ ] Oversell scenario results in `invalid` at Level 2 and does not block the sale or mutate cargo/credits/docs.
- [ ] Sale referencing destroyed/missing source doc results in `invalid`.
- [ ] Temporal contradiction (sale earlier than acquisition for referenced chain) results in `invalid`.
- [ ] Log output includes one concise Level-2 summary per qualifying trigger and does not spam per-frame.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a new game and dock at a location with non-Low customs pressure so depth can reach Level 2.
2. Acquire cargo through normal documented flow.
3. Create an oversell condition (via existing document manipulation or sale flow) and sell; verify Level-2 classification becomes `invalid` and the sale still completes.
4. Create a sale referencing a destroyed/missing source document (using existing destroy/edit path if available); verify `invalid`.
5. Create a temporal contradiction (if supported by doc edit events) and trigger a qualifying inspection; verify `invalid`.
6. Repeat the same trigger with the same state; verify deterministic repeatability of classification/reasons.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing doc fields or incomplete snapshots: downgrade to `suspicious` with an explicit reason; must not crash.
- Empty docs snapshot: Level-2 audit should return `invalid` with a clear reason and must not crash.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Under-specified document schema may make strict invariants hard; prefer `suspicious` unless the chain is logically impossible.
- Avoid introducing new persistence fields; if required data is absent, log and stop rather than inventing.
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