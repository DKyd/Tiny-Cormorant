# Bugfix Job

## Metadata
- Issue/Task ID: issue-0068
- Short Title: Purchase Order dialog opens when entering Port/Market
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Bug Description
When clicking the Port button (entering the Port view), the Purchase Order dialog appears automatically without the player pressing "Create Purchase Order". This is unintended UI state carryover / default visibility.

---

## Expected Behavior
The Purchase Order dialog is hidden by default when entering the Port/Market UI.
It should only appear when the player explicitly triggers it (e.g. presses "Create Purchase Order").

---

## Repro Steps
1. Launch the game.
2. Click the Port button to enter the Port view.
3. Observe the Market view area.

---

## Observed Output / Error Text
- Purchase Order dialog is visible immediately on entering Port (before any user action to open it).

---

## Suspected Area (Optional)
- `MarketPanel` dialog lifecycle / default visibility.
- Potentially `Port.gd` panel initialization / refresh flow.
- PurchaseOrderDialog default `visible` state in the scene.

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
- `scripts/ui/MarketPanel.gd`
- `scenes/ui/MarketPanel.tscn`
- `scripts/Port.gd`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`
- Any other files not in the whitelist

---

## New Files
- None.

---

## Fix Requirements
- On entering the Market panel / Port view, PurchaseOrderDialog must be hidden.
- PurchaseOrderDialog must only be shown in response to the explicit player action (the Create Purchase Order flow).
- The fix must not change buying/selling behavior, market pricing, or time advancement.

---

## Verification

### Manual Test Steps
1. Launch the game and click Port.
   - Confirm PurchaseOrderDialog is NOT visible.
2. Click "Create Purchase Order".
   - Confirm PurchaseOrderDialog appears.
3. Close/cancel the dialog.
   - Confirm it hides again.
4. Leave Port (e.g. go to Bridge) and return to Port.
   - Confirm dialog remains hidden on entry.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0068-bugfix-purchase-order-dialog-default-hidden/`
2) Write this job verbatim to `codex/runs/issue-0068-bugfix-purchase-order-dialog-default-hidden/job.md`
3) Create `codex/runs/issue-0068-bugfix-purchase-order-dialog-default-hidden/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0068-bugfix-purchase-order-dialog-default-hidden`

Codex must write final results only to:
- `codex/runs/issue-0068-bugfix-purchase-order-dialog-default-hidden/results.md`

Results must include:
- Summary of fixes
- Files changed
- Manual test steps run (and outcomes)
- Behavior confirmation (dialog hidden on entry; opens only via explicit action)
- Assumptions made
- Known limitations/TODOs (if any)

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate
