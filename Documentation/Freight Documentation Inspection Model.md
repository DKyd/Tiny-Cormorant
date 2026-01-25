# North Star — Freight Inspections & Evidence Model (Merged)

> **Status:** Authoritative design reference  
> **Scope:** Unified inspection architecture for *Tiny Cormorant*: Customs + Port Authority responsibilities, evidence-based document authenticity, inspection triggers, inspection depth, and roadmap primitives.  
> **Philosophy:** *Perception before simulation.* Inspections evaluate **evidence**, not player intent.

---

## 0) Merge Notes (What Changed)

This merge preserves the original **Evidence-Based Flags Architecture** and integrates the later **Customs Inspection Level** model.

Two explicit clarifications introduced by the newer model:

1. **Checks occur at player-decision boundaries** (fairness + auditability), with one exception: **Port Authority can run compliance checks at Dock/Undock**, which are still player actions.
2. **Level 1 requires real primitives** (required fields + signatures/issuer markers). These are now explicit roadmap features.

**Additional clarification (2026-01):**

* **System entry checks must be deterministic and pressure-driven**, using the **highest-pressure location in the system** as the representative jurisdiction when the player is not docked.

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

**Responsibility boundary:**

* Customs decides **whether an inspection attempt occurs**.
* Customs does **not** compute pressure.
* Customs does **not** evaluate documents.
* Customs never mutates cargo, credits, or freight docs.

---

### 2.2 Port Authority

Port Authority cares about **how** cargo is being carried and handled.

Primary concerns:

* container integrity
* seal authenticity
* manifest discipline
* ship compliance
* operational anomalies

Port Authority primarily evaluates:

> **Document integrity + handling metadata**

---

## 3) Evidence-Based Model

Documents do **not** store a single authenticity truth. Instead, documents accumulate **evidence** via immutable edit events.

Evidence includes:

* edit magnitude
* edit frequency
* time since modification
* tool used / quality
* metadata coherence
* issuer context (future)

---

## 4) FreightDoc Edit Events

Each document modification appends an immutable event:

```gdscript
{
  "event_id": String,
  "event_type": "edit_declared_qty" | "edit_meta" | "destroy_doc",
  "tick": int,
  "source": "captains_quarters",
  "before": Dictionary,
  "after": Dictionary,
  "tool_used": String,
  "quality": int
}
```

---

## 5) When Checks Happen (Trigger Model)

Checks occur only at player-action boundaries.

Canonical triggers:

* Departing a port (Customs clearance)
* Selling cargo (paperwork submission)
* System entry clearance (border-like scrutiny)
* Dock / Undock compliance (Port Authority)

Non-triggers:

* idle UI browsing
* mid-route travel
* background simulation

---

## 6) How Authorities Decide to Check

### 6.1 Customs Pressure

Pressure answers:

* How strongly is governance asserting itself here?

Pressure governs:

* inspection frequency
* maximum inspection depth

### 6.2 System Entry Jurisdiction Selection

When entering a system while not docked:

Customs selects the location with the highest computed customs pressure in the system.

Ties are resolved via lexicographic location ID ordering.

This makes entry checks deterministic and explainable.

### 6.3 Randomness

Randomness:

* affects whether a check occurs
* never affects detection logic
* must be deterministic / seedable

Authorities must not rely on global RNG state.

---

## 7) Inspection Depth Levels

Level 0 — No Check  
Most common outcome.

Level 1 — Surface Compliance  
Detects:

* missing required docs
* missing required fields
* malformed obvious data

Level 2 — Document Audit  
Detects:

* cross-document inconsistencies
* provenance conflicts
* custody contradictions

Level 3 — Reconciliation  
Detects:

* mass / capacity discrepancies

Level 4 — Physical Inspection (Deferred)  
Enables seizures, fines, and holds (future).

---

## 8) Core Worlds as Difficulty Lever

Higher-security jurisdictions unlock deeper inspections.

---

## 9) Smuggling Detectability Map

| Method | First Detectable At |
| --- | --- |
| Container stuffing | Level 3 |
| Provenance laundering | Level 2 |
| Quantity tampering | Level 2–3 |

---

## 10) Roadmap Phases

Phase A — Paperwork Formalism

* Required fields per doc type
* Issuer markers / signatures
* Deterministic inspection rolls

Phase B — Audit Data

* Container capacity
* Sovereignty stamps
* Cross-doc invariants

Phase C — Reconciliation Data

* Hull mass
* Container tare
* Commodity mass

---

## 11) Non-Negotiable Rules

* Detect inconsistencies, not intent
* Player-action boundaries only
* Jurisdiction gates depth
* Randomness affects frequency, not logic
* Reputation biases, never nullifies
* All outcomes must be explainable
* Inspection attempts are deterministic
* Entry jurisdiction = highest-pressure location

---

## 12) Level-2 Customs Audits (Document Chain Coherence)

Level-2 Customs inspections evaluate cross-document coherence, not physical cargo.

Level-2 audits produce an independent audit classification and do not retroactively change Level-1 outcomes.

At this depth, Customs asks:

“Do these documents form a plausible, internally consistent paper trail?”

Level-2 audits do not:

* inspect containers
* verify physical quantities
* enforce penalties
* block player actions

They operate purely on documentary evidence.

### 12.1 Scope of Evaluation

Level-2 audits may compare:

* Bills of Sale ↔ their declared source documents (purchase orders, contracts)
* Aggregate sold quantities ↔ aggregate acquired quantities
* Document lifecycle state (active vs destroyed)
* Container metadata presence and provenance fields
* Temporal ordering (acquisition before sale)

Level-2 audits must not evaluate:

* physical container contents
* ship mass or capacity
* crew actions
* player intent

### 12.2 Classification Semantics

Level-2 audits produce one of three outcomes:

**CLEAN**  
The document chain is internally coherent.

**SUSPICIOUS**  
The chain is coherent but exhibits irregularities, ambiguity, or elevated risk  
(e.g., unusual provenance, seal changes, timing oddities).

**INVALID**  
The chain is internally inconsistent or impossible  
(e.g., overselling, missing sources, destroyed source documents).

IMPORTANT:  
INVALID does not imply seizure, fines, or denial of trade.  
It represents a paperwork failure, not enforcement.

### 12.3 Consequences of Level-2 Failures

At Level 2:

INVALID results in:

* inspection logs
* increased Customs pressure

SUSPICIOUS results in:

* inspection logs
* potential future inspection depth increase

No Level-2 outcome may:

* mutate cargo
* mutate credits
* mutate freight documents
* block movement or trade

### 12.4 Smuggling Implications

Level-2 audits restrict undocumented trade, not smuggling itself.

Smuggling remains possible via:

* laundering illicit cargo through legitimate acquisition documents
* partial sales over time
* jurisdictional arbitrage
* black market channels

Physical concealment and container stuffing are out of scope until Level 3.

If smuggling feels as easy as legal trade, it is not smuggling.
