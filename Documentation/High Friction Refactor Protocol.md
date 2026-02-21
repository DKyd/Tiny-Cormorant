High-Friction Refactor Protocol

Tiny Cormorant Governance Extension

Purpose

This protocol exists to prevent iterative churn, UX drift, and circular rewrites during structural or stateful refactors.

It applies to any job that:

Changes navigation flow

Alters UI behavior

Modifies state transitions

Rewires signals

Removes or repurposes controls

Changes authority boundaries (UI ↔ Bridge ↔ GameState)

If a refactor requires more than one conversational correction, this protocol must be used.

Core Principle

Lock intent before touching code.

Codex executes instructions. It does not reason about evolving intent.
Friction happens when intent is discovered mid-implementation.

Phase 0 — UX / Behavior Lock (Mandatory)

Before any code instructions are given, define a UX Decision Lock block.

Example:

## UX Decision Lock

- MapPanel has no close behavior.
- close_button is permanently repurposed as Dock/Undock.
- Dock only allowed when already in current system.
- No auto-travel + auto-dock.
- UI never mutates GameState directly.

Rules:

This block is immutable for the job.

If the UX changes mid-run, the job must be restarted under a new Issue ID.

Codex must treat this as authoritative.

Phase 1 — Structural Plan (No Code Yet)

Before editing any files, Codex must print:

Planned Changes:

Files to modify:
- file A
- file B

Functions to add:
- func X()
- func Y()

Signals to add/remove:
- signal A
- remove signal B

Connections to add/remove:
- connect A -> B
- remove connect C -> D

Behavior deltas:
- Explicitly list what changes from player perspective

Human must approve this plan before any diff is generated.

If the plan is wrong:

Stop.

Correct the plan.

Do not proceed.

Phase 2 — Scope Lock

Restate whitelist before edits:

Allowed:
- scripts/Bridge.gd
- scripts/MapPanel.gd
- singletons/GameState.gd
- codex/runs/**

Forbidden:
- data/**
- .godot/**
- project.godot
- scenes/** (unless explicitly whitelisted)

Codex must confirm scope before editing.

Phase 3 — Single-Concern Edits

High-friction refactors must be split into atomic steps.

Instead of:

Refactor Docking

Break into:

Add strict GameState API

Update Bridge routing

Update UI signal emission

Remove legacy plumbing

One conceptual change per step.

Small diffs reduce interpretation error.

Phase 4 — Behavior Declaration

If the refactor changes player-visible behavior, it is not a pure refactor.

Declare explicitly:

## Behavior Change Declaration
This job changes player-visible behavior:
- Close button removed.
- Dock only possible when in-system.
- No implicit docking on arrival.

If this section exists:

The job is not a “refactor”.

It is a “behavior change” or “feature change”.

Invariants must be revalidated accordingly.

Phase 5 — Scope Proof Gate (Strict)

Before approval:

Required:

git status

git diff --stat

full git diff

Approval only valid if:

Only whitelisted files modified

No .godot/**

No unintended scene edits

No accidental deletions

No renamed nodes unless specified

Approvals without scope acknowledgment are void.

Anti-Drift Rules

To reduce oscillation:

No Implicit Interpretation

Codex must not reinterpret UI intent.

Codex must not repurpose controls unless explicitly instructed.

Codex must not delete signals unless explicitly instructed.

No Creative Fixes

Codex must not “improve” design unless asked.

Only implement what is specified.

No Silent Cleanup

Dead code removal requires explicit instruction.

Signal removal requires explicit instruction.

No Mid-Run UX Changes

If UX shifts mid-job → terminate run → open new issue.

UI State Pattern (Canonical)

All UI stateful controls must follow:

UI emits signals only.

Bridge mediates transitions.

GameState owns state.

UI never mutates GameState directly.

UI reflects state through refresh methods.

Time only advances through GameState.advance_time(reason).

This pattern prevents hidden side effects.

When To Use This Protocol

Use this protocol when:

You notice repeated rejections.

Diff size grows across iterations.

UX intent is evolving mid-job.

Multiple files are being touched.

State transitions are being altered.

If two conversational corrections occur, stop and switch to this protocol.

Friction Diagnosis Checklist

If a refactor stalls:

Ask:

Did we lock UX intent?

Did we distinguish refactor vs behavior change?

Did we split into atomic steps?

Did we require a pre-edit structural plan?

Did we over-constrain or under-specify?

One of these is almost always the cause.

Strategic Reminder

Governance is not the enemy of speed.

Ambiguity is.

This protocol preserves:

Determinism

Auditability

Scope discipline

Codex control

While eliminating:

Iterative rewrites

Signal churn

Button repurposing mistakes

Scope pollution

Design oscillation

Closing Principle

Lock intent.
Constrain interpretation.
Edit surgically.
Verify scope.
Approve decisively.