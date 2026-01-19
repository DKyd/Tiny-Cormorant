# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0029
- Short Title: Contract Abandonment Semantics via FreightDoc Destruction
- Run Folder Name: issue-0029-feature-contract-abandonment-semantics
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
When a player destroys a **contract** FreightDoc, the associated contract is treated as **abandoned**: it can no longer be completed for reward, but the cargo remains in the player’s hold and remains player-owned.  
Bills of sale and other non-contract FreightDocs are unaffected.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- All FreightDoc mutations (including destruction) continue to occur only via `GameState` APIs.
- Destroying a FreightDoc continues to record evidence (edit event + authenticity effects) exactly as it does now.
- Cargo ownership and quantities do not change as a direct result of contract abandonment (no forced cargo removal or seizure).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- This job must not add inspections, fines, seizures, reputation changes, or enforcement consequences.
- This job must not add save/load migration or new persistence fields (abandonment is runtime-only for now).

---

## Context
Contracts are tracked in `GameState.active_contracts`, and completion currently occurs in `GameState.check_travel_contracts_at(system_id, location_id)` which pays reward, clears contract cargo, and marks docs completed.  
FreightDocs are stored in `GameState.freight_docs`. Contract FreightDocs include a `contract_id`. FreightDoc destruction is already implemented via `GameState.destroy_freight_doc(doc_id, reason, source)` and sets `is_destroyed`, appends a `destroy_doc` event, and emits `freight_doc_changed`.  
Currently, destroying a contract FreightDoc does not impact contract completion semantics, meaning a contract may still be completable even with destroyed paperwork (undesired for upcoming enforcement/inspection loops).

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Add a runtime-only “abandoned contract” state tracked by `GameState` (data structure TBD, e.g. set/dictionary of abandoned contract_ids).
- On successful destruction of a FreightDoc with `doc_type == "contract"` and a valid `contract_id`, mark that contract as abandoned.
- Ensure abandoned contracts are excluded from completion in `check_travel_contracts_at()` (no payout, no cargo clearing, no doc completion marking).
- Add clear log entries when a contract is abandoned due to destroyed paperwork and when a completion attempt is blocked due to abandonment.
- Keep bills of sale and market purchase documents unaffected.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

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

- N/A

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None.

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - None.
- Save/load verification requirements:
  - None.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Destroying a **contract** FreightDoc marks its associated contract as abandoned and emits a single clear log entry indicating abandonment.
- [ ] An abandoned contract cannot be completed for reward at its destination (no payout, no cargo clearing, no doc completion marking), and this emits a single clear log entry.
- [ ] Destroying a **bill_of_sale** FreightDoc does not mark any contract abandoned and does not change contract completion behavior.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Accept a contract, then dock at Captain’s Quarters and destroy the contract FreightDoc (provide any reason). Confirm a log entry indicates the contract was abandoned due to destroyed paperwork.
2. Travel to the contract destination location. Confirm the contract does **not** complete: no reward is paid, cargo is not cleared, and a log entry indicates completion was blocked due to abandonment.
3. Buy a commodity from a market to generate a bill of sale. Destroy the bill of sale FreightDoc. Confirm no contract abandonment occurs (no abandonment log entry), and any unrelated contract completion behavior is unchanged.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Destroying a contract FreightDoc for a contract that is no longer active should not crash and should not spam logs (best-effort: mark abandoned only if the contract_id is currently active).
- If multiple FreightDocs reference the same contract_id, destroying one should be sufficient to abandon the contract (and abandonment should be idempotent).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Contract completion currently marks docs completed and clears cargo; excluding abandoned contracts must not affect normal completion flow for non-abandoned contracts.
- This introduces a new runtime-only state; a future persistence job may need to decide whether abandonment persists across save/load.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0029-feature-contract-abandonment-semantics/`
2) Write this job verbatim to `codex/runs/issue-0029-feature-contract-abandonment-semantics/job.md`
3) Create `codex/runs/issue-0029-feature-contract-abandonment-semantics/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0029-feature-contract-abandonment-semantics`

Codex must write final results only to:
- `codex/runs/issue-0029-feature-contract-abandonment-semantics/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [x] All explicit player actions that succeed or fail emit a clear log entry
- [x] All time advancement paths log a reason and tick delta
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
