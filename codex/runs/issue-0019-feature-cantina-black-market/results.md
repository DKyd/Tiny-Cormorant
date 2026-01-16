# Results: issue-0019-feature-cantina-black-market

## Summary
- Added Cantina access from the Port facility list and wired Back Room to a new Black Market panel.
- Implemented black market offers via Economy and a dedicated BlackMarketPanel buy flow that records Bill of Sale docs with MARKET_KIND_BLACK_MARKET.
- Added close flow for the Black Market panel and guarded GameState signal connections.

## Files Changed
- singletons/Economy.gd: added black market offer retrieval and normalized market_kind support.
- scripts/Port.gd: added Cantina button handling, Cantina/Black Market panel loading, and close wiring.
- scenes/Port.tscn: added Cantina button to the Port facilities row.
- scripts/ui/CantinaPanel.gd: new cantina panel with back room + close signals.
- scenes/ui/CantinaPanel.tscn: new cantina panel scene.
- scripts/ui/BlackMarketPanel.gd: new black market panel, purchase flow, close signal, and guarded signal connections.
- scenes/ui/BlackMarketPanel.tscn: new black market panel scene with Close button.

## Assumptions Made
- Black market offerings reuse Economy price list generation with market_kind = MARKET_KIND_BLACK_MARKET.
- Cantina access is determined by presence of "cantina" or "back_room" in the location's spaces array (treating "back_room" as implying a cantina for access gating).

## Known Limitations / TODOs
- No separate back_room gating beyond Cantina access; back room access is implied once inside the cantina.
- Black market UI uses the same commodity set as legal markets; future curation is deferred.

## Manual Test Plan
1. Dock at a location whose spaces include "cantina" or "back_room".
2. Open the Cantina from the Port UI.
3. Enter the Back Room and open the Black Market panel.
4. Buy an illicit commodity.
5. Open FreightDocsPanel from Port or Bridge and verify the Bill of Sale.
6. Save, reload, and verify cargo and docs persist.
