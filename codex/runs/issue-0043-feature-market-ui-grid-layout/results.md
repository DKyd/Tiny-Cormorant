Summary of changes and rationale
- Added header buttons for purchase order creation and sell manifest actions, wired to emit signals only with no gameplay mutations or logging.

Files changed (with brief explanation per file)
- scenes/MarketPanel.tscn: added header rows with buttons next to Market Goods and Ship Inventory labels.
- scripts/MarketPanel.gd: added signals and button handlers to emit requests without side effects.

Assumptions made
- These signals will be handled by a higher-level controller when the workflow is implemented.

Known limitations or TODOs
- Buttons emit signals only; no behavior beyond UI scaffolding is implemented by design.
