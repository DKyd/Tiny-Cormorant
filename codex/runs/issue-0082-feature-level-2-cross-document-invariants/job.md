# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0082
- Short Title: Formalize Level 2 cross-document invariants (detection-only)
- Run Folder Name: issue-0082-feature-level-2-cross-document-invariants
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Implement **Level 2 inspection depth** as **cross-document invariant checks** that detect inconsistencies between cargo, declarations, and freight documents.  
The output is **evidence-style flags + clear logs** only—no enforcement, no blocking, no economic impact.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspection outcomes remain **deterministic** for the same inputs (cargo state + documents + context); no new randomness or time-based variance is introduced.
- The system remains **detection-only**: no fines, seizures, holds, forced unloads, or any gameplay consequence beyond logs/flags.
- Existing Level 0/1 pressure + trigger behavior continues to function unchanged unless explicitly required for Level 2 wiring.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Add enforcement or penalties (fines, seizures, holds, forced inspections, time delays, tariffs, reputation hits, etc.).
- Add UI changes or new HUD elements (logging is allowed; new UI is not).

---

## Context
Customs currently supports deterministic pressure/triggers and Level 1-style surface compliance checks.  
What’s missing is the next inspection depth: **cross-document invariants** that validate whether multiple records agree (cargo vs declared vs contract/bill-of-sale/etc.) and produce structured evidence flags/log entries without enforcement.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ⬅️ NEW

- Define a small set of **Level 2 invariant checks** (commodity mismatch, quantity mismatch, missing/contradictory document relationships, destroyed-doc-but-cargo-present, etc.).
- Implement a single Customs entry point to evaluate invariants from an inspection context and return **evidence flags** (as structured dictionaries) plus **human-readable logs**.
- Ensure invariant evaluation is **pure/deterministic** (no randomness; only reads current cargo/doc state and provided context).
- Wire Level 2 evaluation into the existing inspection flow at the appropriate point (only when inspection depth >= Level 2) without altering triggers/pressure math.
- Add minimal logging that summarizes: inspection depth, invariant failures found (if any), and counts—no spam.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/Customs.gd`
- `singletons/GameState.gd`

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

- 
- 

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `Customs.evaluate_level2_cross_document_invariants(inspection_ctx: Dictionary) -> Array[Dictionary]` (new; returns evidence flags)
- If needed for wiring: minor update to existing inspection evaluation method(s) in `Customs.gd` to invoke Level 2 checks when depth >= 2 (no signature changes unless unavoidable)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - Not applicable (no new persistence)

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
  - Level 2 invariant results must be deterministic for identical cargo + documents + inspection context.
- What inputs must remain stable?
  - Cargo quantities/types as represented in `GameState` at inspection time; document structures used for declarations/contracts/bills-of-sale (as currently stored).
- What must not introduce randomness or time-based variance?
  - No `rand*`, no time-derived values, no frame-time dependencies. Only evaluate from provided context and current state.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When an inspection runs at depth >= Level 2, Customs produces a deterministic set of Level 2 evidence flags for invariant breaches (or none if clean).
- [ ] Level 2 generates clear, human-readable log entries summarizing invariant results (counts + short reason codes), with no per-frame spam.
- [ ] No enforcement behavior is introduced: the player experience is unchanged except for logs/flags; travel/market/cargo remain unaffected.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and create/enter a scenario where Customs inspection can occur (existing trigger path).
2. Create a **clean** case: cargo + declarations/documents match; trigger an inspection at depth >= Level 2; verify logs show Level 2 ran and produced **0 invariant failures**.
3. Create a **mismatch** case: adjust cargo quantity or commodity so it conflicts with declared/doc values; trigger an inspection at depth >= Level 2; verify logs show **specific invariant breach(es)** and evidence flags are returned/recorded.
4. Repeat the mismatch test twice with identical setup; verify results are **identical** (deterministic).
5. Confirm no penalties occur (no cargo changes, no money changes, no holds, no forced UI flows).

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or partial documents: Level 2 should emit a bounded set of “missing relationship” flags and continue without crashing.
- Empty cargo / zero quantities / unknown commodity IDs: must not crash; should either skip irrelevant checks or emit a clear “cannot evaluate”/“unknown commodity” style flag.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Level 2 checks depend on current document/cargo representations; if structures differ from assumptions, Codex must STOP and report.
- Risk: Over-logging; must keep logs compact and avoid per-item spam.
- Risk: Accidental scope creep into enforcement; must remain detection-only.
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ⬅️ NEW

---

## Governance & Review Gates (Mandatory) ⬅️ NEW
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
  B) Run the current issue’s Closeout Gate (stage → staged diff review → commit → push)
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
  - `git commit -m "<Issue/Task ID>: <Short Title>"`
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
