# North Star Document — Smuggling in *Tiny Cormorant*

> **Status:** Authoritative design reference
>
> **Scope:** Current player-available smuggling methods (implemented or emergent)
>
> **Philosophy:** *Perception before simulation* — smuggling is the manipulation of institutional trust, not stealth gameplay.

---

## Purpose of This Document

This document defines **all forms of smuggling currently available to players** in *Tiny Cormorant*, whether:

* explicitly implemented,
* emergent from existing systems, or
* implicitly supported by current abstractions.

Each smuggling method includes:

* **Description** (what kind of crime this is fictionally)
* **Player Instructions** (how a player performs it today)
* **Current System Support** (why it works now)
* **Customs Detection Vector** (what customs *would* look at later)
* **Notes / Placeholders** for future expansion

This document is a **North Star reference**. It should not drift without deliberate design review.

---

## Smuggling Method 1 — Concealment Inside Sealed Contract Containers

### Description

Hiding illicit goods inside containers that are sealed under a legitimate freight contract and cannot be opened by customs without elevated authority.

This is *institutional concealment*, not physical stealth.

### Player Instructions (Current)

1. Accept a freight contract that generates sealed containers.
2. Unseal the container while in possession of it.
3. Add illicit or undeclared goods to the container.
4. Reseal the container.
5. Transport and deliver or divert the container.

### Current System Support

* Containers are player-controllable objects.
* Sealed status exists and is meaningful.
* Customs cannot currently inspect container contents.
* No ship-level reconciliation of mass vs manifest.

### Customs Detection Vector (Future)

* Ship mass vs declared manifest mass discrepancy.
* Container tare weight vs expected contents.
* Probable cause leading to warrant-based inspection.

### Notes / Placeholders

* Ship mass system (derived, not simulated)
* Container tare + capacity metadata
* Inspection depth ladder (spot → audit → physical)

---

## Smuggling Method 2 — Provenance Laundering via Sovereignty Stamps

### Description

Altering the declared origin of goods by applying a sovereignty stamp that asserts alternate jurisdictional authority, bypassing embargoes or origin-specific tariffs.

This is *political smuggling*, not forgery by default.

### Player Instructions (Current / Partial)

1. Acquire a sovereignty stamp (purchase / quest reward — **TBD**).
2. Apply the stamp to a bill of sale.
3. Sell or transport goods under the new declared provenance.

### Current System Support

* Provenance exists conceptually.
* Bill of sale is authoritative.
* No adversarial authenticity checks yet.
* No embargo or tariff enforcement yet.

### Customs Detection Vector (Future)

* Authenticity of the stamp.
* Jurisdiction recognition at the current system.
* Authority scope mismatch (authentic but ineffective stamp).

### Notes / Placeholders

* Stamp metadata (issuer, authority scope)
* Authenticity scoring integration
* Jurisdiction compatibility rules

---

## Smuggling Method 3 — Quantity Tampering (Clerical Fraud)

### Description

Illicit goods are added to containers, and the declared quantity on documents is modified to remain internally consistent.

This is *bureaucratic falsification*, not concealment.

### Player Instructions (Current)

1. Unseal a container.
2. Add additional goods (licit or illicit).
3. Modify the manifest / bill of sale quantity to match.
4. Reseal container.
5. Transport or sell cargo.

### Current System Support

* Quantities are player-editable.
* Documents are authoritative if self-consistent.
* No reconciliation against container capacity or ship mass.

### Customs Detection Vector (Future)

* Container capacity vs declared quantity.
* Quantity plausibility heuristics.
* Cross-document consistency checks.

### Notes / Placeholders

* Container max capacity metadata
* Quantity plausibility rules
* Optional document revision history

---

## Smuggling Method 4 — Contract Diversion (Cargo Theft)

### Description

Selling contract-bound goods at an unauthorized destination for higher profit, abandoning the original contract.

This is *custodial crime*, not smuggling per se.

### Player Instructions (Current)

1. Accept a freight contract.
2. Transport cargo away from the intended destination.
3. Sell the goods (often on the black market).
4. Abandon or ignore the contract.

### Current System Support

* Contracts do not enforce completion.
* Cargo ownership is effectively transferred.
* No pursuit or restitution system.

### Customs Detection Vector (Future)

* Custody vs ownership discrepancies.
* Contract flags on cargo.
* Suspicious resale of restricted goods.

### Notes / Placeholders

* Contract breach records
* Reputation effects (issuer-specific)
* Increased scrutiny on flagged cargo

---

## Smuggling Method 5 — Jurisdiction Shopping

### Description

Routing goods through systems with lower security or more permissive customs environments to preserve margin and avoid scrutiny.

This is *geographic arbitrage*.

### Player Instructions (Current)

1. Examine system security and customs pressure.
2. Choose longer or indirect routes through permissive systems.
3. Avoid high-security chokepoints.

### Current System Support

* System security exists.
* Customs pressure is visible and deterministic.
* No borders or mid-route inspections.

### Customs Detection Vector (Future)

* Pattern-based scrutiny of suspicious routing.
* Increased inspection likelihood in mismatched routes.

### Notes / Placeholders

* Route risk summaries
* Jurisdiction mismatch warnings

---

## Smuggling Method 6 — Mixed Cargo Camouflage

### Description

Using large quantities of legitimate cargo to mask smaller amounts of illicit or risky goods.

This is *aggregation camouflage*.

### Player Instructions (Current)

1. Load legitimate cargo in bulk.
2. Add illicit or high-margin goods in smaller quantities.
3. Ensure overall shipment appears mundane.

### Current System Support

* Customs pressure is coarse-grained.
* No per-item scrutiny.
* No mixed-load penalties.

### Customs Detection Vector (Future)

* Cargo composition analysis.
* Suspicious ratio heuristics.

### Notes / Placeholders

* Cargo composition summaries
* Risk-weighted cargo scoring

---

## Smuggling Method 7 — Document Minimalism

### Description

Providing only the minimum required documentation to avoid introducing inconsistencies or flags.

This is *bureaucratic risk management*.

### Player Instructions (Current)

1. Generate only required freight documents.
2. Avoid adding optional provenance or metadata.
3. Keep documents sparse and consistent.

### Current System Support

* No penalty for lack of detail.
* Authenticity focuses on contradictions, not absence.

### Customs Detection Vector (Future)

* Absence-based suspicion thresholds.
* Mandatory metadata requirements in high-pressure systems.

### Notes / Placeholders

* Metadata completeness scoring
* System-specific documentation expectations

---

## Smuggling Method 8 — Custodial Ambiguity ("It’s Not Mine")

### Description

Transporting goods under ambiguous ownership or delegated custody to diffuse responsibility.

This is *legal deflection*, not concealment.

### Player Instructions (Current)

1. Carry goods under contract or third-party custody.
2. Avoid explicit ownership transfers.
3. Rely on institutional ambiguity.

### Current System Support

* Ownership and possession are separate concepts.
* No beneficial ownership checks.

### Customs Detection Vector (Future)

* Beneficial ownership tracing.
* Repeated use of custody shields.

### Notes / Placeholders

* Ownership vs custody flags
* Beneficial owner inference (future)

---

## Explicitly Deferred Smuggling Mechanics

The following are **intentionally not implemented yet**:

* Concealed cargo holds (ship enhancements)
* Active scanners / counter-scanners
* Random inspection evasion rolls
* Binary contraband flags

These will be considered only after document- and perception-based smuggling is fully realized.

---

## Closing Principle

> **In *Tiny Cormorant*, smuggling is not about hiding goods.**
> **It is about shaping what institutions believe to be true.**

This document defines the foundation upon which inspections, enforcement, and reputation systems will later be built.
