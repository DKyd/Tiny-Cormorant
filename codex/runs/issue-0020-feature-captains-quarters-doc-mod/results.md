# Results: issue-0020-feature-captains-quarters-doc-mod

## Summary
- Added Captain's Quarters panel UI and GameState FreightDoc mutation APIs with immutable edit events.
- Added runtime FreightDoc normalization and cargo-line detachment on destroy; added edit_noop event for invalid edit requests.

## Files Changed
- singletons/GameState.gd: added edit/destroy APIs, event logging helpers, runtime normalization, and doc detachment logic.
- scripts/ui/CaptainsQuartersPanel.gd: added doc selection UI and controls for edit/destroy actions (read-only UI, no logs).
- scenes/ui/CaptainsQuartersPanel.tscn: created UI scene matching CaptainsQuartersPanel.gd node paths.

## New Public APIs
- GameState.modify_freight_doc(doc_id: String, changes: Dictionary, source: String) -> Dictionary
- GameState.destroy_freight_doc(doc_id: String, reason: String, source: String) -> Dictionary
- GameState.get_freight_doc(doc_id: String) -> Dictionary

## Manual Test Steps
1. Start the game and acquire cargo that generates a Bill of Sale.
2. Open Captain's Quarters via a debug instantiation of CaptainsQuartersPanel.
3. Modify declared quantity on a FreightDoc and verify it appears in inspection UI.
4. Modify container/seal metadata and verify it appears in inspection UI.
5. Destroy the FreightDoc and verify it is flagged destroyed (is_destroyed=true) and detached from cargo lines.
6. Attempt the same actions via a non-Quarters code path and verify failure + log entry.

## Assumptions Made
- Captain's Quarters panel is instantiated manually for now; wiring via Quarters button is deferred to a follow-up job.
- FreightDoc edit events can include the new event_type "edit_noop" for invalid/no-op edit attempts.

## Known Limitations / Follow-ups
- Quarters button wiring is deferred to a follow-up job (no changes to MainGame.gd in this run).
- No persistence added for new fields; runtime-only as specified.
