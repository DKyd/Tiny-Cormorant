Summary
- Added a read-only Selected FreightDoc inspector section and signal-driven refresh flow in Captain's Quarters.
- Preserved selection across list rebuilds and cleared inspector-only fields when the selected doc is missing.
- Ensured empty-selection handling updates action state without wiping user edit inputs.

Files Changed
- scripts/ui/CaptainsQuartersPanel.gd: added inspector bindings, selection-aware refresh, render/empty helpers, and freight_doc_changed handling.
- scenes/ui/CaptainsQuartersPanel.tscn: added InspectorSection nodes and label paths used by the script.

Assumptions Made
- GameState already exposes the freight_doc_changed signal as defined in the active job.

Known Limitations / TODOs
- Inspector content depends on GameState.get_freight_doc returning normalized fields (declared_quantity, container_meta, edit_events).
