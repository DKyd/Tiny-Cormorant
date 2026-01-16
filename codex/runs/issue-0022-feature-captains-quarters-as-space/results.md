# Results: issue-0022-feature-captains-quarters-as-space

## Summary
- Converted Captain's Quarters to a full navigable view and removed overlay-only teardown behavior from the panel.
- Wired the Quarters button to use `_show_view()` and added a dedicated view scene that embeds the existing panel.

## Files Changed
- scripts/MainGame.gd: routes the Quarters button to `res://scenes/CaptainsQuarters.tscn` and removes overlay-only state.
- scripts/ui/CaptainsQuartersPanel.gd: removed Close button handling to rely on global navigation.
- scenes/ui/CaptainsQuartersPanel.tscn: removed the Close button node.
- scenes/CaptainsQuarters.tscn: new view scene embedding the Captain's Quarters panel.

## Assumptions Made
- The Captain's Quarters panel does not require internal close controls when used as a full view.

## Known Limitations / TODOs
- None.
