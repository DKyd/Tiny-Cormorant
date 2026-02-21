# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0089
- Short Title: Implement Level-2 Customs Audits (Minimal Cross-Document Invariants)
- Run Folder Name: issue-0089-level-2-customs-audits-minimal
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Implement **Level-2 Customs audits** that evaluate **cross-document chain coherence** (CLEAN / SUSPICIOUS / INVALID) using minimal invariants, triggered only at player-action boundaries.  
Level-2 results must be **logged** and may **bias future inspection depth/pressure**, but must **not** mutate cargo, credits, or freight documents and must **not** block movement or trade.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- **Player-action boundaries only:** Level-2 audits run only on canonical triggers (Depart, Sell, System Entry, Dock/Undock compliance where applicable).
- **Determinism:** Whether an audit occurs may be roll-based but must be deterministic/seeded; detection logic must not use RNG.
- **No enforcement at Level 2:** No Level-2 outcome may mutate cargo, credits, or freight docs, and may not block any player action.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Implement Level 3 reconciliation (mass/capacity) or Level 4 physical inspection outcomes (fines, seizures, holds).
- Add new UI panels or change market/black market mechanics beyond any needed log/summary surfacing.

---

## Context
Customs currently performs deterministic, pressure-driven checks with inspection depth gating. Level-1 surface compliance exists (required docs/fields as currently implemented) and logs outcomes.  
The North Star defines Level-2 audits as **document-chain coherence checks** that classify results as CLEAN/SUSPICIOUS/INVALID without enforcement.  
What is missing is the concrete Level-2 evaluation pass implementing minimal **cross-document invariants** and producing explainable classification + logs, while preserving determinism and scope boundaries.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a Level-2 audit step callable from existing Customs trigger paths after Level-1 (or when Level-1 passes/exists), respecting the existing depth cap.
- Implement minimal invariant checks:
  - **Quantity conservation / oversell** (aggregate sold must not exceed aggregate acquired for a documented chain)
  - **Destroyed/missing source reference** (sales referencing destroyed/missing sources are INVALID)
  - **Temporal ordering** (acquisition tick must not be after sale tick for the referenced chain)
- Produce a **CLEAN/SUSPICIOUS/INVALID** classification with a structured reasons list suitable for logs.
- Log the Level-2 classification and top reasons; optionally apply **pressure bias hooks** already supported by Customs (if such hooks exist), without introducing enforcement.
- Ensure all randomness remains deterministic and isolated from detection logic.

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
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `Customs.run_level_2_audit(context: Dictionary) -> Dictionary` (new; returns classification + reasons; no side effects beyond logs)
- `GameState.get_freightdoc_chain_snapshot() -> Dictionary` (new or modified; read-only snapshot for audits) *(only if needed; otherwise None)*

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None (preferred). If unavoidable, additions must be backward-compatible and default-safe.
- Migration / backward-compat expectations:
  - Existing saves must load without migration and without null dereferences.
- Save/load verification requirements:
  - Load an existing save (if available) and confirm audits do not crash and produce logs.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Audit occurrence rolls must remain deterministic (seeded by stable context inputs).
  - Audit classification must be fully deterministic given the document/event state.
- What inputs must remain stable?
  - System entry jurisdiction selection uses highest-pressure location (ties lexicographic), per North Star.
  - Trigger contexts (system_id, location_id, action, tick) used for seeding must remain stable.
- What must not introduce randomness or time-based variance?
  - Detection logic must not call RNG or depend on wall-clock time; only game ticks.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When a Level-2-capable check occurs, Customs logs one of: **CLEAN**, **SUSPICIOUS**, **INVALID**, plus at least one reason when not CLEAN.
- [ ] A contrived oversell scenario (sell qty > acquired qty in documents) yields **INVALID** at Level 2 without blocking the sale.
- [ ] A scenario where a sale references a destroyed or missing source doc yields **INVALID** at Level 2.
- [ ] A temporal contradiction (sale tick earlier than acquisition tick for referenced chain) yields **INVALID** at Level 2.
- [ ] No Level-2 path mutates cargo, credits, or freight docs (verified via code inspection + runtime behavior).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a new game in a test galaxy with predictable systems; dock at a port with non-Low customs pressure.
2. Acquire cargo via a documented purchase (creates source docs/events).
3. Create an oversell condition (e.g., manipulate docs or execute a sale that exceeds documented acquisition) and sell cargo.
4. Observe logs: a Level-2 audit should classify **INVALID** and list an oversell reason; the sale should still complete (no enforcement).
5. Create a sale referencing a destroyed/missing source doc (using existing doc-destruction or edit path) and sell; verify **INVALID** logged.
6. Create a temporal contradiction (if supported by doc/event editing); verify **INVALID** logged.
7. Repeat a trigger twice in identical conditions; verify outcomes are deterministic/repeatable.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or incomplete freight doc data in older saves: audit should degrade to **SUSPICIOUS** or skip Level-2 with a log note, but must not crash.
- Systems with no locations: entry jurisdiction selection must remain deterministic; if entry checks are skipped, Level-2 must not run unexpectedly.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Freight-doc chain data may not be in a single canonical structure; avoid introducing new persistence fields if possible.
- Over-scoping into UI or enforcement would violate Non-Goals; keep changes confined to audit evaluation + logs.
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