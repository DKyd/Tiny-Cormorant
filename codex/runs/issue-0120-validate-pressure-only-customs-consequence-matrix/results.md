# Results

## Summary
- Preflight passed in the canonical clone and the job remained scoped to run artifacts only.
- A minimal Godot 4.6.1 headless boot was attempted to validate live runtime behavior, but runtime validation was blocked before interactive scenarios could be exercised.
- Despite that blocker, the current pressure-only customs consequence matrix can still be partially validated from source and prior governed run history: invalid outcomes increase scrutiny, save/load restore is implemented, deterministic decay is implemented, and the current player-facing surfacing is limited to Level 1 plus scrutiny-preview/header messaging.
- No evidence was found for fines, holds, seizures, travel blocking, cargo mutation, credit mutation, or document mutation as automatic consequences of the current inspection outcome paths.

## Environment and Evidence
- Canonical workspace:
  - `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`
- Preflight outcome:
  - branch `master`
  - working tree clean
  - not behind `origin/master`
- Godot runtime binary used for validation attempt:
  - `C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe`
- Code surfaces inspected:
  - `project.godot`
  - `singletons/GameState.gd`
  - `singletons/Customs.gd`
  - `scripts/Port.gd`
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scripts/customs/CustomsLevel2Audit.gd`
  - `scripts/customs/CustomsInvariants.gd`
- Prior runs used as implementation evidence:
  - `issue-0079-level1-pressure-escalation`
  - `issue-0084-persist-customs-pressure-escalation`
  - `issue-0089-level-2-customs-audits-minimal`
  - `issue-0097-surface-scrutiny-depth-bias-port-header`
  - `issue-0098-surface-scrutiny-in-inspection-preview`
  - `issue-0102-formalize-level-2-audit-pipeline`
  - `issue-0108-surface-level1-audit-ui`
  - `issue-0114-deterministic-pressure-decay`
  - `issue-0119-reconcile-inspections-smuggling-customs-roadmap`

## Validation Attempt Matrix

| Scenario | Setup | Action | Expected result | Observed result | Status |
| --- | --- | --- | --- | --- | --- |
| Runtime boot smoke test | Clean canonical clone, Godot 4.6.1 console binary, headless launch from project root | Run `Godot_v4.6.1-stable_win64_console.exe --headless --path <project> --quit-after 5` | Project boots far enough to permit further runtime validation without repo churn | Godot printed generated contracts, then failed with `Unrecognized UID: "uid://djwab4xr50ujm"` and `Failed to instantiate an autoload, can't load from path: .` | `blocked` |
| Repo-churn check after launch | Same as above | Run `git status --short` immediately after headless boot | No forbidden `.godot/**` or other repo churn | Working tree remained clean | `pass` |
| Level 1 pass flow in live UI | Requires successful runtime boot and a deterministic clean-document state | Manual customs inspection from the Port UI | No scrutiny increase, no enforcement, read-only reporting only | Could not execute because runtime boot failed first | `blocked` |
| Level 1 suspicious flow in live UI | Requires successful runtime boot and a deterministic authenticity/modification trigger | Manual customs inspection from the Port UI | Suspicious classification without enforcement; pressure behavior must be observed | Could not execute because runtime boot failed first | `blocked` |
| Level 1 invalid flow in live UI | Requires successful runtime boot and a deterministic invalid-document trigger | Manual customs inspection from the Port UI | Invalid classification, scrutiny increase, customs log entry, no enforcement | Could not execute because runtime boot failed first | `blocked` |
| Level 2 invalid or suspicious flow in live UI | Requires successful runtime boot and a deterministic Level 2 trigger at inspection depth 2 | Manual customs inspection from the Port UI | Level 2 payload generated, classification observed, scrutiny/depth memory observed, no enforcement | Could not execute because runtime boot failed first | `blocked` |
| Save/load persistence observation | Requires successful runtime boot and reproducible pre-save scrutiny state | Save from in-session menu, reload, re-check customs state | Scrutiny deltas and recent Level 2 violation memory restored | Could not execute because runtime boot failed first | `blocked` |
| Deterministic decay observation | Requires successful runtime boot and reproducible elevated scrutiny state | Advance time, re-check customs preview/header | Scrutiny decays deterministically over ticks | Could not execute because runtime boot failed first | `blocked` |

## Startup Blocker
- `project.godot` currently declares:
  - `FeedbackCapture="*uid://djwab4xr50ujm"`
- The attempted headless boot failed with:
  - `ERROR: Unrecognized UID: "uid://djwab4xr50ujm".`
  - `ERROR: Resource file not found: res:// (expected type: unknown)`
  - `ERROR: Failed to instantiate an autoload, can't load from path: .`
- This is enough to block reliable live runtime validation in the current CLI environment.
- The launch attempt did not dirty `.godot/**` or any other tracked file, so the blocker is runtime startup, not forbidden repo churn.

## Behavior Matrix: Confirmed, Partially Confirmed, and Blocked

| Capability | Current state | Evidence | Notes |
| --- | --- | --- | --- |
| Level 1 `clean` path exists | source-confirmed | `GameState.run_customs_inspection()` defaults to `classification = "clean"` and only changes on invalid/suspicious conditions | Live observation blocked |
| Level 1 `suspicious` path exists | source-confirmed | Triggered for no docs, low authenticity, or modification evidence in `GameState.run_customs_inspection()` | Live observation blocked |
| Level 1 `invalid` path increases scrutiny | source-confirmed | `apply_customs_pressure_increase(location_id, "level1_invalid")` is called when Level 1 classification is `invalid` | Implemented by `issue-0079`; live observation blocked |
| Level 2 audit classification exists | source-confirmed | `CustomsLevel2Audit.build_level2_audit()` returns `clean`, `suspicious`, or `invalid` based on failed invariants | Implemented by `issue-0102`; live observation blocked |
| Level 2 `not_evaluable` invariant state exists | source-confirmed | `CustomsInvariants` and `CustomsLevel2Audit` normalize `status = "not_evaluable"`; non-failed invariants do not become findings by themselves | Live observation blocked |
| Level 2 invalid classification increases scrutiny | source-confirmed | `apply_customs_pressure_increase(location_id, "level2_invalid")` is called when `level2_audit.classification == "invalid"` | Live observation blocked |
| Recent Level 2 violations bias future depth | source-confirmed | `_record_customs_level2_invariant_violation()` and `resolve_customs_inspection_depth()` produce `depth_bias` and `max_depth` | Surfaced by `issue-0097` and `issue-0098`; live observation blocked |
| Scrutiny persistence across save/load | source-confirmed | `save_game()` stores `customs_scrutiny_deltas_by_location`; `load_game()` restores it and logs restore count | Implemented by `issue-0084`; live observation blocked |
| Level 2 violation memory persistence | source-confirmed | `save_game()` stores `customs_recent_level2_violation_tick_by_location`; `load_game()` restores it | Live observation blocked |
| Deterministic scrutiny decay | source-confirmed | `_apply_customs_scrutiny_decay(tick_delta)` is called from `advance_time()` | Implemented by `issue-0114`; live observation blocked |
| Log output on inspection result | source-confirmed | `GameState.run_customs_inspection()` logs formatted customs entry; escalation helper adds scrutiny-increase log entry | Live observation blocked |
| Port header scrutiny surfacing | source-confirmed | `scripts/Port.gd` renders `Customs scrutiny: Normal` or `Heightened (+N depth)` from `resolve_customs_inspection_depth()` | Added by `issue-0097`; live observation blocked |
| Inspection preview scrutiny surfacing | source-confirmed | `scripts/Port.gd` preview string includes scrutiny state and resolved max depth | Added by `issue-0098`; live observation blocked |
| Inspection panel Level 1 surfacing | source-confirmed | `CustomsInspectionPanel` renders `level1_audit` via `SurfaceAuditPanel` | Added by `issue-0108`; live observation blocked |
| Inspection panel Level 2 surfacing | gap-confirmed | `CustomsInspectionPanel.gd` has no `level2_audit` rendering path | This is the strongest candidate next feature job |
| Enforcement consequences | source-confirmed absent | `recommended_penalty.should_issue_fine` is hardcoded `false`; no blocking branches were found in inspected customs paths | Live observation blocked, but source strongly supports pressure-only model |

## Pressure-Only Boundary Check
- Confirmed in source:
  - no automatic fines are issued in the current inspection report path
  - no holds, seizure, denial, travel blocking, or reputation effects were found in the inspected customs consequence flow
  - no cargo mutation, credit mutation, or document mutation was found as an automatic side effect of `run_customs_inspection()`
- Remaining caveat:
  - these are source-confirmed conclusions, not full live-interaction confirmations, because startup blocked end-to-end runtime scenario execution

## Dependencies, Blockers, and Reproduction Gaps
- Primary blocker:
  - project startup currently fails in headless validation because the `FeedbackCapture` autoload resolves to a missing UID target
- Secondary blocker:
  - even with startup fixed, this environment lacks a lightweight deterministic harness for forcing specific inspection branches without manual UI driving
- Reproduction gap:
  - there is no documented step-by-step fixture recipe in the repo for producing known Level 1 `suspicious`, Level 1 `invalid`, Level 2 `not_evaluable`, and Level 2 `invalid` cases on demand

## Recommendation
- Next safest job: a narrow `bugfix` or `governance/planning` validation-enabler job to resolve the `FeedbackCapture` autoload startup blocker or otherwise define a reproducible runtime validation path.
- If the human prefers to defer the startup blocker, the next safest feature job is still the read-only Level 2 audit surfacing work identified in `issue-0119`, because the code path exists but the current inspection panel does not surface `level2_audit`.
- Do not move to Level 3 reconciliation or any enforcement work yet.

## Advisory Candidate Follow-Up Jobs

### 1. Fix runtime validation blocker for `FeedbackCapture` autoload
- Target job type: `bugfix`
- Risk level: low
- Likely whitelist:
  - `project.godot`
  - `singletons/FeedbackCapture.gd` or the actual target scene/script path if required
  - active run files
- Narrow goal:
  - make the project boot reliably in Godot 4.6.1 without introducing runtime behavior changes outside startup stability.
- Verification approach:
  - headless boot succeeds and `git status --short` remains clean afterward.

### 2. Add a documented manual validation recipe for inspection outcomes
- Target job type: `planning` or `documentation`
- Risk level: low
- Likely whitelist:
  - a narrow documentation target if explicitly allowed
  - active run files
- Narrow goal:
  - define exact setups for Level 1 clean/suspicious/invalid and Level 2 suspicious/invalid/not-evaluable reproduction.
- Verification approach:
  - a human can follow the steps without guesswork.

### 3. Surface Level 2 audit payload in the inspection UI
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - possibly a new narrow `scripts/ui` helper if needed
  - active run files
- Narrow goal:
  - render existing `level2_audit` classification and findings without changing audit semantics or adding enforcement.
- Verification approach:
  - trigger a Level 2 inspection and confirm deterministic read-only surfacing.

## Non-Goals Preserved
- No enforcement recommendation is made here.
- No roadmap edits were made in this job.
- No runtime, scene, data, or governance files were modified.
