Summary
- Added Packed Tick and Provenance rows to the Captain's Quarters inspector and render them from container_meta.
- Cleared the new read-only fields in the inspector empty state without touching edit inputs.

Files Changed
- scripts/ui/CaptainsQuartersPanel.gd: bound packed tick/provenance labels and added formatting helpers for display.
- scenes/ui/CaptainsQuartersPanel.tscn: added Packed Tick and Provenance label nodes under InspectorGrid.

Assumptions Made
- container_meta may omit packed_tick/provenance for older FreightDocs, and the UI should show defaults.

Known Limitations / TODOs
- Provenance formatting is minimal text; a richer layout may be desired later.
