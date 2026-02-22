# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0100
- Short Title: Formalize Level 2 cross-document invariants
- Run Folder Name: issue-0100-formalize-level-2-cross-document-invariants
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
Implement **Level 2** inspection logic that evaluates **cross-document invariants** (consistency constraints spanning multiple freight documents and container metadata) and produces deterministic, explainable inspection results.  
This deepens the evidence model without introducing enforcement outcomes (no fines, holds, seizures, or reputation impacts).

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- All Level 2 invariant evaluations are **deterministic** given the same stable inputs (system_id, location_id/checkpoint, time_tick, cargo state, and document/evidence state).
- Level 2 checks **never modify cargo, credits, time, or documents**; they only read state and emit inspection findings/evidence flags/logs.
- Level 1 behavior and triggers remain valid and unchanged unless explicitly required to route into Level 2 evaluation.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do NOT add enforcement (no fines, seizures, holds, arrests, confiscation, tariffs, delays, or reputation changes).
- Do NOT add new document types, UI panels, or market/black market behavior changes.

---

## Context
Customs/inspection infrastructure currently supports deterministic **pressure bucketing**, **Level 1** inspection triggers, and an evidence/flags architecture. We need to formalize **Level 2**: checks that validate consistency across multiple documents (contract / bill of sale / declaration / container metadata) and convert violations into structured findings that can later drive depth escalation and consequences.  
A prior placeholder/plan for “cross-document invariants” exists conceptually (and may have been started), but the invariant rules are not yet implemented as a coherent, testable, deterministic evaluation layer with clear logging.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a small, explicit **Level 2 invariant registry** and evaluator that consumes an inspection context and returns a list of invariant failures (with stable IDs).
- Implement an initial set of high-signal invariants (see Acceptance Criteria) using only existing state/doc fields; if a required field is missing, the evaluator must degrade gracefully and report a “not evaluable” result rather than inventing data.
- Ensure invariant evaluation is called only when inspection depth reaches Level 2 (or equivalent), without altering existing Level 1 trigger logic.
- Emit clear, non-spammy logs describing which invariant failed and why (player-readable summary, not raw internal dumps).
- Update/extend evidence flags or inspection findings in a forward-compatible way (read-only now; consequences later).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`
- `res://singletons/GameState.gd`

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

- `res://scripts/customs/CustomsInvariants.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `Customs.evaluate_level2_invariants(ctx: Dictionary) -> Array` (new or formalized; returns Array of invariant result dictionaries)
- `CustomsInvariants.evaluate(ctx: Dictionary) -> Array` (new helper module)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None (must load older saves unchanged)
- Save/load verification requirements:
  - Load an existing save and confirm inspections still run and no new required fields cause null errors.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Which invariants are evaluated, their pass/fail outcomes, and their reported stable IDs/messages for a given state snapshot.
- What inputs must remain stable?
  - `system_id`, effective checkpoint/location_id, `GameState.time_tick` (or equivalent), cargo quantities, and the relevant document/container metadata fields and evidence flags.
- What must not introduce randomness or time-based variance?
  - No `randi()`, `Time.get_unix_time_*`, wall-clock usage, or non-seeded randomness in invariant evaluation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When an inspection reaches Level 2, the system evaluates a defined set of cross-document invariants and returns a structured list of results (each with stable `id`, `severity`/`weight`, and human-readable `summary`).
- [ ] At minimum, the following invariant types exist and can fail deterministically when state is inconsistent:
  - Quantity consistency between declaration and cargo/container manifest totals
  - Origin/destination consistency between contract and declaration (where fields exist)
  - Timestamp/order consistency between contract acceptance / bill of sale / declaration (where fields exist)
  - Container seal / container metadata consistency vs declared container fields (where fields exist)
- [ ] If required inputs for an invariant are missing, the invariant yields a deterministic “not evaluable” outcome (or is skipped with a logged reason) rather than throwing errors or inventing values.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a test save or start a new run; create/obtain a basic legal cargo contract and complete the normal document flow to reach an inspection at Level 2 depth (or use existing deterministic triggers that route to Level 2).
2. Verify logs/report: Level 2 invariants run and return either “all pass” or a list of checks with stable IDs.
3. Create an inconsistency:
   - Modify cargo quantities (or simulate a mismatch via existing debugging hooks/evidence flags if available), or break a container meta value if such a mechanism exists.
4. Re-run the same inspection context (same system/location/tick) and confirm the same invariant fails deterministically with the same ID and message.
5. Load an older save (pre-0100) and confirm no errors occur and Level 1 inspections still behave identically.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing documents or partially populated documents: evaluator must skip/not-evaluable with an explicit reason and no crashes.
- Systems with no locations / checkpoint fallback paths: Level 2 must still evaluate deterministically using the effective checkpoint id logic already established.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Document schemas may not yet expose all fields needed for certain invariants; implementation must be conservative and not assume missing fields exist.
- Avoid UI work: findings should be logged and returned structurally for future UI/report surfaces.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/<Run Folder Name>/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/<Run Folder Name>/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0100: Formalize Level 2 cross-document invariants"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

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