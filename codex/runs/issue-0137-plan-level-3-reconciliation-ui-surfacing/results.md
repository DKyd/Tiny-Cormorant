# Results

## Summary
- Planned Level 3 reconciliation UI surfacing as display-only inspection panel work.
- Recommended placement: add a `Level 3 Reconciliation` section in the existing Customs inspection panel directly after the current Level 2 Documentary Audit section and before Document Summary.
- Recommended future report source: existing `report["level3_reconciliation"]` only; UI must not call `CustomsLevel3Reconciliation`, `Customs.run_level_3_reconciliation`, or `GameState.run_customs_inspection`.
- Recommended first implementation modifies only the existing panel scene/script if practical:
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - `scripts/ui/CustomsInspectionPanel.gd`
- Preserved boundaries: no helper semantics change, no pressure/scrutiny effects, no logs, no enforcement, no triggers, no depth policy, no runtime behavior changes in this planning job.

## Preflight Evidence
- branch: `master`
- `git status --short`: clean before scaffolding
- HEAD before this job: `9e34b3a issue-0136: Attach Level 3 reconciliation report to inspections`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0136-attach-level-3-reconciliation-report-to-inspections`
- `git fetch origin`: completed
- `git status -sb`: `## master...origin/master`

## Workspace Path Evidence
- `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` does not exist on this machine.
- `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant` exists and is the current working tree.
- This matches the prior OneDrive Desktop redirect clarification. No governance files were modified.

## Evidence Reviewed
- Prior results:
  - `issue-0123-surface-level-2-audit-details-in-inspection-ui`
  - `issue-0135-plan-level-3-read-only-inspection-integration`
  - `issue-0136-attach-level-3-reconciliation-report-to-inspections`
- Source surfaces read-only:
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - `scripts/ui/SurfaceAuditPanel.gd`
  - `scenes/ui/SurfaceAuditPanel.tscn`

## Capability Definition
Level 3 UI surfacing means:
- Display an already-attached `level3_reconciliation` payload in the Customs inspection panel.
- Communicate documentary/runtime reconciliation status in plain language.
- Show a compact summary and a bounded number of findings/not-evaluable reasons.
- Handle missing, malformed, clean, suspicious, and not-evaluable reports without crashing.

It does not mean:
- no helper invocation from UI
- no runtime inspection calls from UI
- no pressure/scrutiny effects
- no logs
- no enforcement
- no fines, holds, seizures, travel denial, cargo denial, reputation effects, physical inspections, or forced offloads
- no changes to Level 1/Level 2 UI behavior
- no changes to helper output semantics

## Recommended UI Placement
Recommended future placement in `CustomsInspectionPanel.tscn`:
- After:
  - `Level2AuditLabel`
  - `Level2AuditStatus`
  - `Level2AuditFindings`
  - `Level2AuditBoundary`
- Before:
  - `DocSummaryLabel`

Recommended new nodes:
- `Level3ReconciliationLabel: Label`
- `Level3ReconciliationStatus: Label`
- `Level3ReconciliationFindings: RichTextLabel`
- `Level3ReconciliationBoundary: Label`

Rationale:
- Level 3 builds naturally on Level 1/Level 2 inspection detail.
- Putting it before Document Summary keeps audit/reconciliation content grouped.
- It avoids a broader panel redesign and preserves the current simple vertical layout.
- The existing panel already uses a label + status + rich text pattern for Level 2, which Level 3 can mirror.

Do not create a new reusable subpanel in the first implementation unless the existing layout cannot safely hold the extra text. A new subpanel would be acceptable later, but it expands review surface.

## Player-Facing Wording
Recommended section title:
- `Level 3 Reconciliation`

Recommended boundary note:
- `Level 3 compares declared paperwork against the current cargo snapshot. This panel is informational only and does not apply fines, holds, seizures, cargo denial, or travel blocking.`

Recommended status text:
- Missing payload:
  - Status: `No Level 3 reconciliation attached.`
  - Body: `This inspection did not include a Level 3 reconciliation payload.`
- Empty payload:
  - Status: `No Level 3 reconciliation attached.`
  - Body: `This inspection did not include a Level 3 reconciliation payload.`
- Malformed payload:
  - Status: `Level 3 reconciliation unavailable.`
  - Body: `Level 3 payload was attached, but its outcome was missing or malformed.`
- `classification == "clean"`:
  - Status: `Outcome: Clean`
  - Body: `Declared cargo and runtime cargo are within reconciliation tolerance.`
- `classification == "suspicious"`:
  - Status: `Outcome: Suspicious`
  - Body lead: `Reconciliation found report-only mismatches.`
  - Finding lines should avoid enforcement wording.
- `classification == "not_evaluable"`:
  - Status: `Outcome: Not evaluable`
  - Body lead: `Reconciliation could not fully evaluate the available paperwork and cargo snapshot.`

Avoid these words/phrases in first UI surfacing:
- `fine`
- `seize`
- `seizure`
- `hold`
- `detain`
- `confiscate`
- `contraband action`
- `travel denied`
- `cargo denied`
- `physical inspection`
- `search ordered`
- `penalty`

Exception:
- The boundary note may say “does not apply fines, holds, seizures, cargo denial, or travel blocking” to explicitly deny enforcement.

## Detail Level
Recommended display limit:
- Show up to 3 suspicious findings.
- Show up to 3 not-evaluable reasons.
- If more exist, add:
  - `Additional Level 3 items omitted from this view.`

Finding line format:
- `- {code}: {message}`
- Optional suffix for stable details:
  - `[Reason: {reason}. Commodity: {commodity_id}.]`

Not-evaluable line format:
- `- Not evaluable: {reason}`
- Optional suffix:
  - `[Commodity: {commodity_id}. Doc: {doc_id}.]`

Do not dump raw dictionaries into UI.
Do not show totals by default in the first surfacing job unless needed to explain a mismatch. If totals are shown, keep them compact:
- `Declared mass: {declared_mass_total}; runtime mass: {runtime_mass_total}; allowed delta: {allowed_delta_mass}.`

Recommended field priority:
- Status/classification first.
- Helper `summary` second if non-empty and safe.
- Suspicious findings third.
- Not-evaluable reasons fourth.
- Totals only for mass mismatch findings or a later polish job.

## Fallback Behavior
Required future UI behavior:
- Absent `level3_reconciliation`: safe “not attached” text.
- Empty dictionary: safe “not attached” text.
- Non-dictionary payload: malformed text.
- Missing/blank `classification`: malformed text.
- Missing `findings`: treat as no findings if classification is `clean`, otherwise mention findings payload is unavailable.
- Non-array `findings`: malformed findings text.
- Missing `not_evaluable`: treat as no not-evaluable items.
- Non-array `not_evaluable`: mention not-evaluable payload is malformed.
- Missing `summary`: use classification-specific fallback body.

Reasoning:
- The panel should never crash because a report is absent, partial, or malformed.
- Missing Level 3 is normal because attachment only occurs for `max_depth >= 3`.

## Dependencies And Blockers
Ready:
- `report["level3_reconciliation"]` is attached by issue-0136 when `max_depth >= 3`.
- Existing Customs inspection panel already renders Level 1 and Level 2 payloads.
- Existing panel has defensive Level 2 formatting helpers that can guide Level 3 formatting.

Limitations:
- Current normal inspection depth resolves only up to `2`, so a normal player path may not naturally show Level 3 yet.
- Manual validation may need a controlled inspection report or direct UI call with a fixture report containing `level3_reconciliation`.
- Container/tare checks may often be `not_evaluable` until `container_class_id` metadata exists.
- The panel currently has a simple vertical layout and no scroll container in the scene text readout; adding more text could crowd smaller viewports.

Potential blocker:
- If manual visual testing shows the current panel cannot fit Level 3 text comfortably, a separate UI structure job should add scrolling or a compact audit section pattern before richer content is added.

## Candidate Job Sequence
### 1. Surface Existing Level 3 Reconciliation In Inspection Panel
- Target job type: feature
- Risk level: medium-high
- Likely whitelist:
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- Narrow goal:
  - display existing `report["level3_reconciliation"]` payload in the current Customs inspection panel using safe fallback text and bounded details.
- Verification approach:
  - static search proves UI does not call helper/runtime inspection functions.
  - fixture/direct `set_report(...)` checks for absent, malformed, clean, suspicious, and not-evaluable payloads.
  - Godot headless scene load succeeds.
  - manual path `Main Menu -> New Game -> Bridge -> Port -> Customs` still opens the panel.
  - no `Log.add_entry`, pressure, enforcement, cargo, save/load, travel, or singleton calls added.
- Explicit non-goals:
  - no helper changes
  - no integration changes
  - no pressure/log/enforcement changes
  - no depth policy change
  - no broad visual redesign

### 2. Add Compact Scroll/Layout Support If Needed
- Target job type: UI feature
- Risk level: medium
- Likely whitelist:
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - `scripts/ui/CustomsInspectionPanel.gd` only if node paths change
  - future active run folder files
- Narrow goal:
  - make the existing inspection panel accommodate Level 1, Level 2, Level 3, document summary, and close button on smaller viewports.
- Verification approach:
  - visual/manual check at common desktop window sizes.
  - no report formatting or helper changes unless strictly required by node path updates.
- Explicit non-goals:
  - no new audit semantics
  - no pressure/log/enforcement changes
  - no art/polish pass beyond layout necessity

### 3. Add Inert Runtime Container Class Attachment
- Target job type: feature
- Risk level: medium-high
- Likely whitelist:
  - `singletons/GameState.gd`
  - possibly `scripts/freight/FreightDocRules.gd`
  - future active run folder files
- Narrow goal:
  - make future Level 3 container/tare checks evaluable by adding stable `container_class_id`.
- Verification approach:
  - generated docs include stable class IDs.
  - existing Level 1/Level 2 UI and report behavior remains unchanged.
- Explicit non-goals:
  - no UI surfacing changes
  - no pressure/log/enforcement changes

### 4. Plan Level 3 Depth Policy
- Target job type: planning
- Risk level: high
- Likely whitelist:
  - future active planning folder only
- Narrow goal:
  - decide when normal inspections may reach `max_depth >= 3`.
- Verification approach:
  - planning/source review only.
- Explicit non-goals:
  - no code changes
  - no pressure/enforcement/UI changes

### 5. Plan Pressure/Scrutiny Consequences, If Any
- Target job type: planning
- Risk level: high
- Likely whitelist:
  - future active planning folder only
- Narrow goal:
  - decide whether Level 3 findings should ever affect scrutiny.
- Verification approach:
  - planning only.
- Explicit non-goals:
  - no runtime changes
  - no physical inspections
  - no fines, holds, seizures, forced offloads, cargo denial, or travel blocking

## Likely Whitelist For First UI Implementation
Recommended:
- `scenes/ui/CustomsInspectionPanel.tscn`
- `scripts/ui/CustomsInspectionPanel.gd`
- `codex/runs/ACTIVE_RUN.txt`
- future active run folder files

Avoid:
- `scripts/customs/CustomsLevel3Reconciliation.gd`
- `singletons/GameState.gd`
- `singletons/Customs.gd`
- `scripts/customs/CustomsReportFormatter.gd`
- `data/**`
- `scenes/**` other than `scenes/ui/CustomsInspectionPanel.tscn`
- `scripts/**` other than `scripts/ui/CustomsInspectionPanel.gd`
- `project.godot`

Conditional:
- A new `Level3ReconciliationPanel.tscn` and `scripts/ui/Level3ReconciliationPanel.gd` should be a separate job unless the existing panel becomes unworkable.

## Verification Strategy For Future UI Job
Static checks:
- `rg "level3_reconciliation" scripts/ui scenes/ui`
- `rg "CustomsLevel3Reconciliation|run_level_3_reconciliation|run_customs_inspection|Log.add_entry|apply_customs_pressure_increase|add_cargo|remove_cargo|save_game|load_game" scripts/ui scenes/ui`
- `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`

Functional formatting cases:
- Missing `level3_reconciliation`
- Empty dictionary
- Non-dictionary payload
- Clean payload with empty findings
- Suspicious payload with quantity/mass findings
- Not-evaluable payload with missing container class reasons
- Malformed findings/not-evaluable arrays
- Long findings list to confirm display cap

Manual UI checks:
- Open the panel through `Main Menu -> New Game -> Bridge -> Port -> Customs`.
- Confirm existing Level 1 and Level 2 sections still render.
- Confirm Level 3 absent state is clear and non-alarming.
- Use a controlled fixture/manual call if available to pass a report with `level3_reconciliation`.
- Confirm no UI text implies enforcement.

No-side-effect checks:
- The future UI script should only read the report dictionary and set label/text values.
- It must not call `GameState`, `Customs`, `Log`, helper scripts, cargo mutation, save/load, travel, or pressure APIs.

## Final Recommendation
Proceed with a single narrow UI feature job that adds a Level 3 display section to the existing Customs inspection panel. Keep it bounded to current scene/script files, display only existing `level3_reconciliation`, and use safe wording that frames Level 3 as informational reconciliation rather than enforcement.

Defer any scroll/layout restructuring, container metadata, depth policy, pressure effects, and enforcement discussions to separate governed jobs.

## Non-Goals Preserved
- No runtime game behavior changed.
- No scenes, UI scripts, data, singletons, helper/harness files, project settings, documentation roadmap files, or governance files were modified.
- No UI surfacing was implemented.
- No pressure/scrutiny effects, logs, triggers, or enforcement were authorized.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
