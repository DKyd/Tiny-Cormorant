# Freight Documentation Inspection Model
## Evidence-Based Flags Architecture

This document describes the long-term inspection and smuggling architecture for Tiny Cormorant.
It is not a feature job. It defines conceptual ground truth used by future systems
(customs, port authority, contracts, law enforcement).

---

## Core Principle

Inspections do NOT directly evaluate player intent or skill.
They evaluate **evidence left behind by document manipulation**.

Players succeed or fail inspections based on:
- What they changed
- How much they changed
- How well they executed the change
- Where and by whom the inspection occurs

This ensures fairness, auditability, and extensibility.

---

## Authority Split (Conceptual)

### Customs
Customs cares about **what** is being carried across jurisdictions.

Primary concerns:
- Commodity legality
- Declared quantity vs actual quantity
- Declared value vs plausible value
- Origin / destination rules
- Duties, tariffs, embargoes
- Paper trail coherence

Customs primarily compares:
> Cargo reality vs Declared reality

---

### Port Authority
Port authority cares about **how** cargo is being carried and handled.

Primary concerns:
- Container integrity
- Seal authenticity
- Hazard handling compliance
- Manifest discipline
- Ship compliance
- Operational anomalies

Port authority primarily evaluates:
> Document integrity + handling metadata

---

## Evidence-Based Model

Documents do NOT store a single “authenticity” truth.
Instead, they accumulate **evidence** through player actions.

### Evidence Sources
Each illegal or questionable action creates an immutable record:

- Edit magnitude (how much changed)
- Edit frequency (how often changed)
- Time since last modification
- Tool used (or lack thereof)
- Metadata coherence (seals, container IDs)
- Issuer context (future)
- Route/system scrutiny (future)

This evidence is stored as an **event log**, not as a single score.

---

## FreightDoc Edit Events (Conceptual)

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
