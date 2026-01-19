Summary
- Refactored log rendering to use Log entry accessors with category-based color rendering and a Dev-only context prefix while keeping UI-only behavior.
- Updated LogPanel layout to add a Dev toggle header, use RichTextLabel output, and widen the panel for readability.

Files Changed
- singletons/Log.gd: added canonical entry storage with context/category capture and public accessors while keeping legacy messages in sync.
- scripts/ui/LogPanel.gd: render entries with RichTextLabel color stack, dev prefix toggle, and robust node guards.
- scenes/ui/LogPanel.tscn: added Dev toggle header row, replaced ItemList with RichTextLabel, enabled unique-name wiring, and widened minimum width.

New Public APIs
- Log.add_entry(text: String, category: String = "")
- Log.get_entry_count() -> int
- Log.get_entry(index: int) -> Dictionary
- Log.get_entry_text(index: int) -> String
- Log.get_entry_category(index: int) -> String
- Log.get_entry_context(index: int) -> Dictionary

Manual Test Steps
- Not run (not requested).

Assumptions Made
- RichTextLabel stack API (push_color/add_text/pop) is available in the current Godot 4.x runtime.
- LogPanel is the only consumer requiring the legacy messages list.

Known Limitations / TODOs
- Category colors are provisional and may be adjusted once category taxonomy is finalized.
