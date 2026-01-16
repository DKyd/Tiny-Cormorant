Summary
- Added Authenticity and Evidence rows to the Captain's Quarters inspector and render them from GameState's derived values.
- Ensured inspector empty state clears the new read-only fields without touching edit inputs.

Files Changed
- scripts/ui/CaptainsQuartersPanel.gd: bind authenticity/evidence labels and format evidence flags for display.
- scenes/ui/CaptainsQuartersPanel.tscn: add Authenticity and Evidence label nodes under InspectorGrid.

Assumptions Made
- GameState.get_doc_authenticity and GameState.get_doc_evidence_flags are present and return runtime-only values as specified in issue-0024.

Known Limitations / TODOs
- Evidence formatting is a simple comma-separated list; future UI may want richer presentation.
