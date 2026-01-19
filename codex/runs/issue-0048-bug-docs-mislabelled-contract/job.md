# Bugfix Job

## Metadata (Required)
- Issue/Task ID: Issue-0048
- Short Title: Purchase Order Docs Mislabelled as Contract in Log and Port Docs
- Run Folder Name: issue-0048-bug-docs-mislabelled-contract
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Bug Description
When a Purchase Order FreightDoc exists, the UI/log formatting treats it as if it were a contract.  
In the Log and the Port ? Docs list, Purchase Order docs display using contract-style wording and route formatting (e.g., “(contract): Core-00 -> Core-00”), which is misleading.

---

## Expected Behavior
Purchase Order FreightDocs must be labeled and summarized as Purchase Orders (acquisition documents), not as contracts.  
The Log and Port ? Docs list must display doc summaries that respect `doc_type`.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Launch the game and dock at any location that has a market.
2. Open Market and buy any commodity to generate a Purchase Order doc.
3. Open Captain’s Quarters (to confirm doc_type is `purchase_order`) and then open Port ? Docs and click the doc to emit its log detail.

---

## Observed Output / Error Text
Include exact text if applicable (UI message, error, log line).

- Log shows contract-style wording for the Purchase Order, e.g.:
  - `Doc FDOC-0001 (contract): Core-00 -> Core-00, status=active.`
- Port ? Docs list shows contract-style route formatting, e.g.:
  - `[FDOC-0001] Core-00 -> Core-00 (active)`

---

## Suspected Area (Optional)
List files/systems you believe are involved.
This is a hint, not a directive.

- Port Docs list label formatting (likely `scripts/Port.gd` and/or a Docs panel script)
- FreightDoc summary/log detail formatting (where “(contract)” is emitted)

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/Port.gd`
- `scripts/ui/DocsPanel.gd` (or whichever script builds the Port ? Docs list + selection log output)
- `singletons/GameState.gd` (ONLY if the mislabelled summary string is generated here)

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

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Purchase Order docs are displayed as `purchase_order` (or “Purchase Order”) in the Log detail output (no “(contract)” wording).
- [ ] Port ? Docs list rows for Purchase Order docs do not use contract route formatting (`origin -> destination`) and instead show a Purchase Order-appropriate summary.
- [ ] Contract docs (existing behavior) still display exactly as before in both Log detail output and Port ? Docs list.

---

## Regression Checks
List behaviors that must still work after the fix.

- Selecting a contract doc in Port ? Docs still emits the same contract-formatted log detail line as before.
- Captain’s Quarters FreightDoc inspector still renders container meta fields (packed tick, provenance, seal state/id) correctly.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Dock at a market location, buy a commodity to generate a Purchase Order.
2. Open Port ? Docs and verify the Purchase Order row label is not contract-formatted.
3. Click the Purchase Order doc and verify the emitted log detail describes it as a Purchase Order (not contract).
4. Generate or select an existing Contract doc and verify it still displays using the old contract route formatting and log detail wording.

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
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
