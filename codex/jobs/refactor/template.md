# Refactor Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:            # REQUIRED (e.g. issue-0016-refactor-debug-cleanup)
- Job Type: refactor
- Author (human):
- Date:

---

## Goal
Describe the structural improvement being made and why.
No behavior change.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

Add job-specific invariants here if needed.

---

## Scope

### Files Allowed to Modify (Whitelist)
-
-

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Describe structural cleanup or consolidation.
2) Describe how call sites are updated.
3) Describe how behavior equivalence is preserved.

---

## Verification

### Manual Test Steps
1.
2.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

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
- Summary of refactor
- Files changed
- Manual test results
- Confirmation behavior is unchanged
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
