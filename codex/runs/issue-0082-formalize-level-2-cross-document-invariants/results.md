# Results

## Summary
- Formalized Level-2 audit findings with stable invariant IDs (L2-01..L2-13) and severity, and derive classification solely from findings.
- Locked oversell semantics to only flag when a source actually has availability (sold_qty > available and available > 0).

## Files Changed
- `res://singletons/GameState.gd`: standardize Level-2 findings with invariant IDs and severity-driven classification.
- `codex/runs/issue-0082-formalize-level-2-cross-document-invariants/results.md`: record the locked invariant list and job outputs.

## New Public APIs
- None.

## Manual Test Steps
1. Start a new game, dock at a market, buy a commodity to generate a purchase_order.
2. Travel to another system and sell half legally; then travel again and sell the remainder legally. Trigger inspections where max depth can reach 2 and confirm Level-2 remains CLEAN with no invariant violations.
3. Create an INVALID chain (e.g., destroy a source purchase_order referenced by an existing bill_of_sale, or oversell beyond source quantity if achievable) and trigger a max-depth-2 inspection; confirm Level-2 becomes INVALID and reports the expected invariant code(s).

## Assumptions Made
- The existing Level-2 audit rule set is the authoritative basis for the invariant list and message text.
- Oversold detection should only fire when a source has positive availability (per approved semantic A).

## Known Limitations / Follow-ups
- Invariants rely on current freight doc fields; legacy docs missing expected fields may still classify as INVALID based on current rules.

## Level-2 Cross-Doc Invariants (Phase 4.0 Locked)

L2-01
- Rule: A bill of sale referenced in the audit set must not be destroyed.
- Rationale: A destroyed sales record invalidates the paper trail.
- Failure classification: INVALID
- Evidence/log reason string: "Destroyed bill of sale detected: %s."

L2-02
- Rule: Bills of sale must include a cargo_lines array.
- Rationale: Missing cargo lines makes the sale unverifiable.
- Failure classification: INVALID
- Evidence/log reason string: "Missing cargo lines for bill of sale %s."

L2-03
- Rule: Each bill of sale line must include a commodity_id and sold_qty > 0.
- Rationale: Invalid line data cannot be reconciled to sources.
- Failure classification: INVALID
- Evidence/log reason string: "Invalid bill of sale line for %s."

L2-04
- Rule: Each bill of sale line must include at least one source entry.
- Rationale: A sale without provenance breaks the chain.
- Failure classification: INVALID
- Evidence/log reason string: "Missing sources for bill of sale %s."

L2-05
- Rule: Each source entry must include a non-empty doc_id and qty > 0.
- Rationale: Invalid source entries are not auditable.
- Failure classification: INVALID
- Evidence/log reason string: "Invalid source entry on bill of sale %s."

L2-06
- Rule: Each source doc_id referenced by a bill of sale must exist in the audit set.
- Rationale: Missing source documents are contradictions.
- Failure classification: INVALID
- Evidence/log reason string: "Missing source document %s for bill of sale %s."

L2-07
- Rule: Each source document must be a purchase_order or contract.
- Rationale: Non-acquisition documents cannot justify sales provenance.
- Failure classification: INVALID
- Evidence/log reason string: "Invalid source type %s on bill of sale %s."

L2-08
- Rule: Source documents referenced by sales must not be destroyed.
- Rationale: Destroyed sources invalidate the chain.
- Failure classification: INVALID
- Evidence/log reason string: "Destroyed source document %s referenced by bill of sale %s."

L2-09
- Rule: Source documents must include the sold commodity in their declared quantities.
- Rationale: A source lacking the commodity cannot justify the sale.
- Failure classification: INVALID
- Evidence/log reason string: "Source %s lacks commodity %s for bill of sale %s."

L2-10
- Rule: Source acquisition tick must not be later than the bill of sale tick when both are known.
- Rationale: A sale cannot predate its acquisition.
- Failure classification: INVALID
- Evidence/log reason string: "Source %s post-dates bill of sale %s."

L2-11
- Rule: Purchase-order sources should include a purchase tick when a bill of sale tick exists.
- Rationale: Missing timing metadata reduces audit confidence but is not contradictory.
- Failure classification: SUSPICIOUS
- Evidence/log reason string: "Missing source tick for bill of sale %s."

L2-12
- Rule: The sum of valid source quantities must match sold_qty for each bill of sale line.
- Rationale: Mismatched totals indicate an incoherent chain.
- Failure classification: INVALID
- Evidence/log reason string: "Source totals do not match sold quantity for bill of sale %s."

L2-13
- Rule: Aggregate sold quantity from a source must not exceed that source's available quantity when availability is positive.
- Rationale: Overselling contradicts the acquisition record.
- Failure classification: INVALID
- Evidence/log reason string: "Oversold source %s for commodity %s."
