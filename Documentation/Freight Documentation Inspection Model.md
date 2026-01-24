# North Star — Freight Inspections & Evidence Model (Merged)

> **Status:** Authoritative design reference
>
> **Scope:** Unified inspection architecture for *Tiny Cormorant*: Customs + Port Authority responsibilities, evidence-based document authenticity, inspection triggers, inspection depth, and roadmap primitives.
>
> **Companions:**
>
> * *North Star — Smuggling in Tiny Cormorant*
> * *North Star — Customs Detection & Inspection Model* (superseded by this merge)
>
> **Philosophy:** *Perception before simulation.* Inspections evaluate **evidence**, not player intent.

---

## 0) Merge Notes (What Changed)

This merge preserves the original **Evidence-Based Flags Architecture** and integrates the later **Customs Inspection Level** model.

Two explicit clarifications introduced by the newer model:

1. **Checks occur at player-decision boundaries** (fairness + auditability), with one exception: **Port Authority can run compliance checks at Dock/Undock**, which are still player actions.
2. **Level 1 requires real primitives** (required fields + signatures/issuer markers). These are now explicit roadmap features.

If we later want mid-route inspections, they must be a deliberate late-game feature and remain deterministic/seeded.

---

## 1) Core Principle

Inspections do **NOT** directly evaluate player intent or reflex skill.
They evaluate **evidence left behind by document manipulation and handling**.

Players succeed or fail inspections based on:

* what they changed
* how much they changed
* how often they changed
* how well they executed the change (tool/quality)
* where and by whom the inspection occurs (jurisdiction + authority)

This ensures fairness, auditability, and extensibility.

---

## 2) Authority Split (Conceptual)

### 2.1 Customs

Customs cares about **what** is being carried across jurisdictions.

Primary concerns:

* commodity legality (future)
* declared quantity vs plausible quantity
* declared value vs plausible value (future)
* origin / destination rules
* duties, tariffs, embargoes (future)
* paper trail coherence (chain consistency)

Customs primarily compares:

> **Cargo reality (or inferred reality) vs Declared reality**

---

### 2.2 Port Authority

Port authority cares about **how** cargo is being carried and handled.

Primary concerns:

* container integrity
* seal authenticity
* hazard handling compliance (future)
* manifest discipline
* ship compliance
* operational anomalies

Port authority primarily evaluates:

> **Document integrity + handling metadata**

---

## 3) Evidence-Based Model (Authenticity as Evidence, Not a Score)

Documents do **NOT** store a single “authenticity” truth.
Instead, documents accumulate **evidence** through player actions.

### 3.1 Evidence Sources (Conceptual)

Each illegal or questionable action creates an immutable record, such as:

* edit magnitude (how much changed)
* edit frequency (how often changed)
* time since last modification
* tool used (or lack thereof)
* metadata coherence (seals, container IDs)
* issuer context (future)
* route/system scrutiny (future)

Evidence is stored as an **event log**, not a single score.

---

## 4) FreightDoc Edit Events (Conceptual)

Each document modification appends an event:

```gdscript
{
  "event_id": String,
  "event_type": "edit_declared_qty" | "edit_meta" | "destroy_doc",
  "tick": int,
  "source": "captains_quarters",
  "before": Dictionary,
  "after": Dictionary,
  "tool_used": String,
  "quality": int,        # player skill / tool quality signal
}
```

### 4.1 Notes

* Events are immutable once recorded.
* Later systems should prefer **explaining outcomes** by citing these evidence events.

---

## 5) When Checks Happen (Trigger Model)

Checks occur only at **player-decision boundaries** to preserve fairness and clarity.

### 5.1 Canonical Triggers

1. **Departing a Port** (Customs clearance)
2. **Selling Cargo** (paperwork submission)
3. **Entering High-Security / Core Systems** (border-like scrutiny)
4. **Dock / Undock Compliance** (Port Authority) — still a player action

### 5.2 Explicit Non-Triggers

Customs and Port Authority do **not**:

* interrupt idle UI browsing
* perform mid-route checks (unless deliberately introduced later)
* act without a player-triggered action

---

## 6) How Customs/Authority Decides to Check

### 6.1 Customs Pressure (Primary Driver)

Inspection likelihood is governed by the existing helper:

```gdscript
GameState.get_customs_pressure_bucket(context) -> Low | Elevated | High | Unknown
```

Pressure determines:

* how often checks occur
* the **maximum inspection depth** allowed

This is where the “randomness rubber meets the road.”

---

### 6.2 Randomness (Bounded, Explainable, Seedable)

Randomness exists to prevent perfect optimization.

Constraints:

* randomness decides **whether** a check occurs
* logic decides **what inconsistencies are detectable**
* results should be **seedable/reproducible**

---

### 6.3 Reputation (Planned)

Reputation modifies frequency and caps depth.

* good reputation: fewer/shallower checks
* bad reputation: more/deeper checks

Reputation never makes checks impossible.

---

## 7) Inspection Depth Levels (Unified)

Inspection depth determines **what inconsistencies an authority is allowed to detect**.

---

### Level 0 — No Check

Most common; player proceeds.

---

### Level 1 — Surface Compliance Check (All Systems)

> **Minimal but real, by design.** This introduces low-grade tedium that rewards careful smugglers.

Allowed detections:

* missing required document types for the action
* missing required fields
* invalid issuer markers / signatures
* malformed obvious data (e.g., negative qty)

Requires roadmap primitives:

* required field definitions per doc type
* lightweight signature/issuer model
* validation hooks

Authority notes:

* Customs uses Level 1 for basic clearance compliance.
* Port Authority uses Level 1 to validate seals/handling metadata presence.

---

### Level 2 — Document Audit (High-Security / Core Systems)

Allowed detections:

* cross-check between documents (manifest ↔ bill of sale)
* quantity ↔ container capacity
* provenance ↔ sovereignty stamp
* stamp authenticity check
* custody/ownership contradictions (where represented)

Jurisdiction lever:

* Core worlds/capitals enable Level 2 by default.

---

### Level 3 — Reconciliation Check (Very High Security or Triggered)

Allowed detections:

* ship mass reconciliation:

  * declared cargo mass
  * container tare
  * hull baseline
* discrepancy thresholds establish probable cause

Notes:

* Level 3 does not open containers by default.
* It exists to detect sealed-container stuffing and clean-doc lies.

---

### Level 4 — Physical / Warrant Inspection (Deferred)

Allowed actions:

* open sealed containers
* verify contents directly
* enable seizures/fines/holds

Explicitly deferred until enforcement systems exist.

---

## 8) Core Worlds as Difficulty Lever

High-depth audits and reconciliation checks should be limited to:

* core worlds
* capital systems
* high-security jurisdictions

This preserves frontier freedom and enables spatial difficulty scaling.

---

## 9) Mapping to Smuggling Methods (Detectability)

| Smuggling Method                              | First Detectable At                         |
| --------------------------------------------- | ------------------------------------------- |
| Sealed contract container stuffing            | Level 3 (Reconciliation)                    |
| Provenance laundering via sovereignty stamp   | Level 2 (Audit)                             |
| Quantity tampering to match illicit additions | Level 2 → Level 3                           |
| Contract diversion (resale off-route)         | Level 2 (contextual)                        |
| Jurisdiction shopping                         | Not illegal by itself                       |
| Mixed cargo camouflage                        | Level 3 (composition heuristics; future)    |
| Document minimalism                           | Level 2 (absence rules; future)             |
| Custodial ambiguity (“it’s not mine”)         | Level 2 (ownership/custody signals; future) |

---

## 10) Roadmap Features Required (Grouped by Phase)

### Phase A — Paperwork Formalism (Enables Level 1)

* Define **required fields** per freight doc type
* Add **issuer markers / signatures** (lightweight)
* Add validation hooks for Surface Compliance Check

### Phase B — Audit Data (Enables Level 2)

* Container capacity metadata
* Sovereignty stamp metadata + authenticity checks
* Cross-doc linking invariants (manifest ↔ bill of sale ↔ containers)

### Phase C — Reconciliation Data (Enables Level 3)

* Ship hull baseline mass
* Container tare weights
* Commodity mass/weight per unit
* Discrepancy tolerance rules

### Deferred (Do Not Implement Yet)

* Enforcement actions (fines/seizures/holds)
* Container opening / warrant mechanics
* Patrol AI / border simulation

---

## 11) Non-Negotiable Rules

1. Authorities detect **inconsistencies**, not intent.
2. Checks occur only at **player-action boundaries**.
3. Inspection depth is gated by **jurisdiction**.
4. Randomness affects **frequency**, not logic.
5. Reputation biases outcomes, never nullifies systems.
6. Every detection step must be **explainable**.

---

## Closing Principle

> If smuggling feels as easy as legal trade, it is not smuggling.

The friction should live in paperwork, planning, and institutional literacy — not reflexes or equipment.
