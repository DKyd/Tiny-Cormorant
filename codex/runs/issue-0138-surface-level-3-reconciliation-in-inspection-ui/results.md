# Results

## Summary
- Surfaced the existing `report["level3_reconciliation"]` payload in the Customs inspection panel as display-only text.
- Added a Level 3 Reconciliation section directly after the existing Level 2 Documentary Audit section and before Document Summary.
- Added defensive formatting for absent, empty, malformed, clean, suspicious, and not-evaluable Level 3 payloads.
- Capped displayed Level 3 findings and not-evaluable entries at 3 each, with an omission note for longer lists.
- Preserved boundaries: no helper calls from UI, no runtime inspection calls, no pressure/log/enforcement behavior, no data/model changes, and no Level 1/Level 2 behavior changes.

## Rationale
- `issue-0136` already attaches `level3_reconciliation` to eligible inspection reports.
- UI surfacing should only render that existing report dictionary, keeping reconciliation semantics owned by the existing helper and integration path.
- Mirroring the existing Level 2 label/status/findings/boundary pattern keeps the change narrow and reviewable.

## Files Changed
- `scenes/ui/CustomsInspectionPanel.tscn`
  - Added `Level3ReconciliationLabel`, `Level3ReconciliationStatus`, `Level3ReconciliationFindings`, and `Level3ReconciliationBoundary` after the Level 2 section.
- `scripts/ui/CustomsInspectionPanel.gd`
  - Added onready references for Level 3 UI nodes.
  - Added `_set_level3_reconciliation(...)` and formatting helpers for safe display-only rendering.
  - Hooked Level 3 rendering into `set_report(...)` and `_set_empty_report()`.
- `codex/runs/ACTIVE_RUN.txt`
  - Updated active run to `issue-0138-surface-level-3-reconciliation-in-inspection-ui`.
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/job.md`
  - Recorded the complete job template.
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/results.md`
  - Recorded this closeout evidence.

## UI Behavior Added
- Missing or non-dictionary `level3_reconciliation`:
  - Status: `No Level 3 reconciliation attached.`
  - Body: `This inspection did not include a Level 3 reconciliation payload.`
- Empty dictionary:
  - Same safe not-attached fallback.
- Missing or blank `classification`:
  - Status: `Level 3 reconciliation unavailable.`
  - Body: `Level 3 payload was attached, but its outcome was missing or malformed.`
- Clean:
  - Status: `Outcome: Clean`
  - Uses report summary if present, otherwise a safe clean fallback.
- Suspicious:
  - Status: `Outcome: Suspicious`
  - Shows summary plus up to 3 finding lines.
  - If the findings payload is missing or malformed, the UI says so without crashing.
- Not evaluable:
  - Status: `Outcome: Not evaluable`
  - Shows summary plus up to 3 not-evaluable reasons.
  - If the not-evaluable payload is missing or malformed, the UI says so without crashing.

## Assumptions Made
- The existing panel has enough vertical room for the first narrow Level 3 section; broader scroll/layout work remains separate if manual testing shows crowding.
- The UI should always show a Level 3 section with a safe absent-state message, because normal inspection reports may not include Level 3 payloads.
- The report payload order is already deterministic, so the UI preserves incoming order instead of resorting findings.
- The boundary note may explicitly say the panel does not apply fines, holds, seizures, cargo denial, or travel blocking because that denies enforcement rather than implying it.

## Verification
- Preflight:
  - branch: `master`
  - `git status --short`: clean before scaffolding
  - HEAD before this job: `b10e8b8 issue-0137: Plan Level 3 reconciliation UI surfacing`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0137-plan-level-3-reconciliation-ui-surfacing`
  - `git fetch origin`: completed
  - `git status -sb`: `## master...origin/master`
- Godot executable:
  - `Test-Path 'C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe'`: `True`
- Godot validation:
  - Command: `& 'C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe' --headless --quit --path .`
  - Exit code: `0`
  - Output: none
- Post-Godot working tree:
  - `git status --short` showed only the whitelisted modified files and active run folder.
  - No `.godot/**` churn appeared.
- Whitespace:
  - `git diff --check`: passed with no output.
- Static no-side-effect searches:
  - `rg "CustomsLevel3Reconciliation|run_level_3_reconciliation|run_customs_inspection|Log\.add_entry|apply_customs_pressure_increase|add_cargo|remove_cargo|save_game|load_game" scripts/ui/CustomsInspectionPanel.gd scenes/ui/CustomsInspectionPanel.tscn`
  - Result: no matches.
  - `rg "GameState|Customs\.gd|Customs\." scripts/ui/CustomsInspectionPanel.gd scenes/ui/CustomsInspectionPanel.tscn`
  - Result: no matches.
- Level 2 policy check:
  - `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`
  - Result: existing `L2INV-001` and `policy_disabled_until_level3` markers remain present.

## Known Limitations / TODOs
- Normal player inspection depth may still not naturally produce Level 3 payloads until a separate depth policy job changes that behavior.
- Container/tare portions of Level 3 may remain `not_evaluable` until a separate inert container class metadata job exists.
- If manual viewport testing shows the panel is crowded, handle scrolling or compact layout in a separate UI layout job.
- This job does not surface totals beyond finding/detail text and does not change helper semantics.

## Non-Goals Preserved
- No `Customs.gd`, `GameState.gd`, helper, harness, data, save/load, pressure, log, trigger, or enforcement files were modified.
- UI code reads only the report dictionary and sets label text.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads were introduced.
