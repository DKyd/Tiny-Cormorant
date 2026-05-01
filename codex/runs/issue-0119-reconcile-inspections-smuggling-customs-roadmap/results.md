# Results

## Summary
- Reconciled `Documentation/Roadmap — Inspections, Smuggling, And Customs` against the current repository state and recent completed inspection/customs runs.
- Marked the roadmap’s previous Phase 3 status as stale: pressure-only scrutiny consequences and Level 2 documentary audit infrastructure are already substantially implemented.
- Produced an advisory candidate job sequence for the next safe milestone work, with explicit risk, likely whitelist sketches, verification approach, and deferred-enforcement boundaries.

## Evidence Used
- Roadmap baseline:
  - `Documentation/Roadmap — Inspections, Smuggling, And Customs`
- Recent run evidence reviewed:
  - `issue-0078-inspection-preview`
  - `issue-0079-level1-pressure-escalation`
  - `issue-0083-l2-audit-visibility-customs-logs`
  - `issue-0084-persist-customs-pressure-escalation`
  - `issue-0089-level-2-customs-audits-minimal`
  - `issue-0095-deterministic-inspection-depth-bias-from-violations`
  - `issue-0097-surface-scrutiny-depth-bias-port-header`
  - `issue-0098-surface-scrutiny-in-inspection-preview`
  - `issue-0099-prune-scrutiny-memory`
  - `issue-0101-extract-doc-rules-and-customs-report-formatting`
  - `issue-0102-formalize-level-2-audit-pipeline`
  - `issue-0103-bug-l2-invariant-summary-diagnostics`
  - `issue-0104-bug-l2-invariants-not-evaluable-reasons`
  - `issue-0105-bug-l2-invariant-sample-show-reason`
  - `issue-0107-formalize-level-1-surface-compliance`
  - `issue-0108-surface-level1-audit-ui`
  - `issue-0109-l2-invariants-chain-coherence`
  - `issue-0110-refactor-deprecate-legacy-level2-audit`
  - `issue-0111-l2-purity-disable-cargo-snapshot`
  - `issue-0112-phase-a-issuer-markers-level1`
  - `issue-0114-deterministic-pressure-decay`
  - `issue-0116-evaluate-desloppify-quality-audit-workflow`

## Reconciled Capability State
- Completed:
  - deterministic inspection triggers and Level 1 paperwork formalism
  - read-only inspection preview
  - scrutiny state surfacing in the Port header and preview
  - pressure-only scrutiny escalation, persistence, and deterministic decay
  - Level 1 audit formalization and UI surfacing
- Substantially complete:
  - Level 2 documentary audit pipeline
  - Level 2 diagnostics, logging, and deterministic depth bias from recent violations
  - documentary-only chain-coherence detection
- Future:
  - Level 3 reconciliation data primitives
  - Level 3 read-only reconciliation and probable-cause flags
  - any enforcement, physical inspection, or Port Authority simulation

## Candidate Future Job Sequence

### 1. Read-only Level 2 audit surfacing in inspection UI
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scripts/ui/SurfaceAuditPanel.gd`
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - `scenes/ui/SurfaceAuditPanel.tscn`
  - possibly `scripts/Port.gd` if explicit-action backfill needs a narrow extension
- Narrow goal:
  - surface existing `level2_audit` payload clearly to the player without changing audit semantics or enforcement.
- Verification approach:
  - manually trigger an inspection that reaches Level 2 and confirm deterministic, read-only display of classification, findings, and not-evaluable reasons.

### 2. Runtime validation pass for current pressure-only consequence matrix
- Target job type: `planning`
- Risk level: low
- Likely whitelist:
  - run folder files only, unless a documentation target is explicitly allowed
- Narrow goal:
  - validate and document the actual live behavior of Level 1 and Level 2 pressure-only escalation, persistence, and decay before further milestone work.
- Verification approach:
  - manual Godot runtime scenarios covering pass, suspicious, invalid, save/load continuity, and time-based decay.

### 3. Narrow Level 2 documentary-gap fill after validation
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `scripts/customs/CustomsInvariants.gd`
  - `scripts/customs/CustomsLevel2Audit.gd`
  - `singletons/Customs.gd`
  - `singletons/GameState.gd` only if required for report integration
- Narrow goal:
  - add only the specific documentary invariant gaps that validation proves are still missing, without introducing cargo reconciliation or enforcement.
- Verification approach:
  - deterministic input fixtures and manual inspection flows showing stable findings ordering and clear classification.

### 4. Level 3 reconciliation data primitives
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `data/**`
  - possibly `singletons/GameState.gd`
  - possibly `scripts/customs/**`
- Narrow goal:
  - add hull baseline mass, container tare weights, commodity mass-per-unit, and tolerance-rule data structures without activating enforcement.
- Verification approach:
  - static data inspection plus manual confirmation that no gameplay action is blocked and no enforcement path is introduced.

### 5. Level 3 read-only reconciliation audit
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `scripts/customs/**`
  - `singletons/Customs.gd`
  - `singletons/GameState.gd`
  - narrow UI files if surfacing is included
- Narrow goal:
  - activate documentary-versus-physical reconciliation checks as read-only or pressure-only signals, with probable-cause flags but no fines, holds, or seizures.
- Verification approach:
  - manual scenarios with deterministic mismatches and confirmation that outcomes remain advisory or pressure-only.

### 6. Optional external-audit-informed runtime cleanup, only after roadmap work
- Target job type: `refactor` or `governance`, depending on scope
- Risk level: medium
- Likely whitelist:
  - to be defined narrowly by a later job
- Narrow goal:
  - address a specific Desloppify finding only if it clearly supports the reconciled roadmap and is translated into a normal governed job.
- Verification approach:
  - standard staged diff review plus proof that the cleanup supports, rather than displaces, roadmap priorities.

## Dependencies, Blockers, and Manual Verification Gaps
- Many recent inspection/customs runs were implemented and statically verified in CLI context, but manual Godot runtime verification is still missing for several milestone edges.
- The code history clearly supports documentary audit and pressure-only scrutiny progression, but it is less explicit about exact live escalation semantics for every Level 1 versus Level 2 classification branch.
- Level 3 is intentionally blocked on new data primitives because Level 2 purity explicitly deferred cargo reconciliation until a later milestone.

## Unresolved Ambiguities
- The roadmap can safely mark Level 2 infrastructure as substantially complete, but a validation pass is still recommended before claiming every planned documentary rule is fully player-visible and runtime-confirmed.
- The exact remaining Level 2 invariant gaps should be determined from targeted validation, not from the stale roadmap text alone.

## Recommendation
- Continue feature-roadmap work before any Desloppify-informed runtime cleanup.
- The safest next executable job is a narrow, read-only Level 2 audit surfacing job or a planning validation pass, not enforcement and not broad customs refactoring.
- Keep enforcement, physical inspections, and Port Authority simulation explicitly deferred until later milestone planning says otherwise.
