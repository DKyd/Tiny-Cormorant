# Results

Summary
- Updated Black Market scene hierarchy to mirror MarketPanel and added Sell Manifest Inventory button in the inventory header.
- Wired BlackMarketPanel to use PurchaseOrderDialog and added a sell dialog flow that sells with black market market_kind.

Files changed
- `scenes/ui/BlackMarketPanel.tscn`: added InfoRow nodes, offers/inventory column structure, SellManifestInventoryButton, and PurchaseOrderDialog instance.
- `scripts/ui/BlackMarketPanel.gd`: updated node paths, grid wiring, purchase dialog setup, and added sell dialog flow for black market sales.

Manual test steps
- Not run (manual verification required).

Known limitations
- None.
