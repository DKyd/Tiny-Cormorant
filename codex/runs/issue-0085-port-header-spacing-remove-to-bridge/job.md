# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0085
- Short Title: Remove redundant Port "To Bridge" button and de-cramp header/menu spacing
- Run Folder Name: issue-0085-port-header-spacing-remove-to-bridge
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Clean up the Port header area by removing the redundant `To Bridge` button at
`MarginContainer/VBoxContainer/HeaderRow/ToBridgeButton`, and improve spacing/layout so the Port header + tabs do not feel cramped in the embedded MainGame context.

This is structural UI cleanup only: Port should not duplicate shell navigation owned by MainGame.

No behavior change: Bridge navigation remains available via MainGame’s global UI; this removes only redundant in-Port navigation and improves readability.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.
- No changes to economic values, inspection logic, or time advancement.
- No MainGame shell/navigation redesign.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Port remains usable when embedded in MainGame (no missing-node errors, no layout breakage).
- Any required navigation to Bridge remains accessible via MainGame (Port does not become a navigation dead-end).

---

## Scope

### Files Allowed to Modify (Whitelist)
- `scenes/Port.tscn`          # remove button node + layout spacing adjustments
- `scripts/Port.gd`           # remove signal hookup/handler if it only exists for the button
- `scripts/ui/**`             # only if a shared style/spacing constant is used by Port header

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Remove the redundant Port-local navigation control:
   - Delete `HeaderRow/ToBridgeButton` from `scenes/Port.tscn`
   - Remove any connected signals / handlers in `scripts/Port.gd` that only exist to support it
2) Improve Port header/menu spacing (without changing semantics):
   - Increase padding/margins around `HeaderRow` and the tab row, or adjust container separation
   - Ensure the header does not reserve space for removed controls (no empty gaps)
   - Confirm layout remains stable across resolutions/aspect ratios typical for your playtests
3) Preserve behavior equivalence:
   - Do not change tab logic, docking logic, or any state reads/writes
   - Only adjust UI structure + presentation

---

## Verification

### Manual Test Steps
1. Launch into MainGame -> dock at a port -> open Port UI:
   - Confirm no errors about missing nodes or invalid signal connections.
2. Visually verify Port header and tabs:
   - Header no longer shows a `To Bridge` button.
   - Tabs/header have comfortable spacing (no cramped corner).
3. Confirm navigation still works:
   - Use MainGame’s global navigation (Bridge/Port/Captain’s Quarters) to leave Port and return.
4. Open/close Market, Contracts, Ship, Cantina, Docs, Customs tabs:
   - Confirm no layout regressions, clipping, or unexpected resizing.

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
