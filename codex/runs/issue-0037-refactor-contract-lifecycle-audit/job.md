# Refactor Job

## Metadata (Required)
- **Issue/Task ID:** Issue-0037  
- **Short Title:** Contract Lifecycle Audit & Tightening  
- **Run Folder Name:** issue-0037-refactor-contract-lifecycle-audit  
- **Job Type:** refactor  
- **Author (human):** Douglass Kyd  
- **Date:** 2026-01-19  

---

## Goal
Audit and tighten the full contract lifecycle to ensure all contract-related queries and transitions consistently respect authoritative state and lifecycle invariants.

This refactor aims to eliminate structural ambiguity and future leak risks while preserving **identical gameplay behavior**.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.
- No persistence or save/load work.
- No UI changes or new visual indicators.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- `GameState` remains authoritative for all contract transitions and queries.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Abandoned contracts never count as active destinations or completable obligations.
- Completed contracts remain historically visible and non-actionable.

---

## Scope

### Files Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `singletons/Contracts.gd` *(if lifecycle helpers are defined or consumed here)*
- `scripts/MapPanel.gd` *(only if non-authoritative reads are discovered)*

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Enumerate the full contract lifecycle (generated ? accepted ? active ? completed / abandoned).
2) Audit all helpers and call sites that:
   - Check contract “active” status
   - Count destinations
   - Gate completion
3) Ensure all such checks route through authoritative `GameState` public APIs.
4) Remove or consolidate any duplicate, implicit, or state-guessing logic.
5) Preserve exact runtime behavior while improving structural clarity and future-proofing.

---

## Verification

### Manual Test Steps
1. Accept, complete, and abandon contracts and verify behavior is unchanged.
2. Confirm Galaxy Map destination counts remain correct in all cases.
3. Trigger inspections and ensure contract-related logging remains unaffected.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched
- [ ] No abandoned or completed contracts reappear as active

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0037-refactor-contract-lifecycle-audit/`
2) Write this job verbatim to `codex/runs/issue-0037-refactor-contract-lifecycle-audit/job.md`
3) Create `codex/runs/issue-0037-refactor-contract-lifecycle-audit/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0037-refactor-contract-lifecycle-audit`

Codex must write final results only to:
- `codex/runs/issue-0037-refactor-contract-lifecycle-audit/results.md`

Results must include:
- Summary of refactor
- Files changed
- Manual test results
- Confirmation that behavior is unchanged
- Follow-ups / known gaps (if any)

---

## Migration Notes
None.

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate
