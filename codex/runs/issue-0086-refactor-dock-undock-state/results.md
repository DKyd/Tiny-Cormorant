# Issue 0086 Results

## Final Decision
Intentional behavior decision adopted:
- MapPanel has no close action; the former `close_button` is repurposed as Dock/Undock.

## Implementation Summary

### GameState (`singletons/GameState.gd`)
- Added strict player-facing transition APIs:
  - `dock_to_location(location_id)`
  - `undock()`
- Preserved legacy internal authority path:
  - `set_current_location()` remains intact and is not replaced by strict docking logic.

### MapPanel (`scripts/MapPanel.gd`)
- `close_button` is wired as Dock/Undock control:
  - `close_button.pressed -> _on_dock_button_pressed`
- Emits `undock_requested` when currently docked.
- Emits `navigate_to_location_requested(system_id, location_id)` only when undocked and a valid in-system location is selected.
- `Set Course` on a location now requests system course only (no implicit dock).
- Dock button state refresh (`_refresh_dock_button_state`) added at required call sites:
  - after `_refresh_all()`
  - `_on_tree_item_selected()`
  - `_on_search_text_changed()`
  - `_on_search_clear_pressed()`
  - on `GameState.location_changed`

### Bridge (`scripts/Bridge.gd`)
- Removed `close_requested` wiring from map panel.
- Handles `undock_requested -> _on_map_undock_requested`.
- Docking via `navigate_to_location_requested` now only succeeds when target location is in current system (no auto-travel + auto-dock).

## Manual Test Results
Runtime/manual playthrough was not executed in this terminal-only pass, so outcomes are recorded as not validated in-engine.

1. Start docked at a location -> button shows "Undock" -> press -> location clears:
- Result: FAIL (not executed manually)
2. While in-system, select location in current system -> button shows "Dock" (enabled) -> press -> docks:
- Result: FAIL (not executed manually)
3. Select location in different system -> button disabled (or warns) -> Set Course requests system travel only:
- Result: FAIL (not executed manually)
4. After arriving new system, confirm undocked -> select in-system location -> Dock works:
- Result: FAIL (not executed manually)

## Known Nits
- Non-blocking: `_on_location_changed()` currently calls `_refresh_dock_button_state()` in addition to deferred `_refresh_all()`.

## Scope Proof

### git status
```text
On branch master
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   codex/runs/ACTIVE_RUN.txt
	modified:   scripts/Bridge.gd
	modified:   scripts/MapPanel.gd
	modified:   singletons/GameState.gd

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	codex/runs/issue-0085-bug-cannot-dock-at-locations/
	codex/runs/issue-0086-refactor-dock-undock-state/

no changes added to commit (use "git add" and/or "git commit -a")
```

### git diff --stat
```text
 codex/runs/ACTIVE_RUN.txt |   2 +-
 scripts/Bridge.gd         |  42 ++++------------
 scripts/MapPanel.gd       | 126 ++++++++++++++++++++++++++++------------------
 singletons/GameState.gd   |  46 ++++++++++++++++ -
 4 files changed, 133 insertions(+), 83 deletions(-)
warning: in the working copy of 'codex/runs/ACTIVE_RUN.txt', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'singletons/GameState.gd', CRLF will be replaced by LF the next time Git touches it
```

### git diff
```diff
diff --git a/codex/runs/ACTIVE_RUN.txt b/codex/runs/ACTIVE_RUN.txt
index be87e04..6eafef4 100644
--- a/codex/runs/ACTIVE_RUN.txt
+++ b/codex/runs/ACTIVE_RUN.txt
@@ -1 +1 @@
-issue-0084-persist-customs-pressure-escalation
+issue-0086-refactor-dock-undock-state
diff --git a/scripts/Bridge.gd b/scripts/Bridge.gd
index e483196..c3fbdd1 100644
--- a/scripts/Bridge.gd
+++ b/scripts/Bridge.gd
@@ -1,4 +1,3 @@
-# res://scripts/Bridge.gd
 extends Control
@@ -95,8 +94,8 @@ func _wire_map_panel(panel: Node) -> void:
 		panel.connect("navigate_to_system_requested", Callable(self, "_on_map_navigate_to_system_requested"))
 	if panel.has_signal("navigate_to_location_requested"):
 		panel.connect("navigate_to_location_requested", Callable(self, "_on_map_navigate_to_location_requested"))
-	if panel.has_signal("close_requested"):
-		panel.connect("close_requested", Callable(self, "_on_map_close_requested"))
+	if panel.has_signal("undock_requested"):
+		panel.connect("undock_requested", Callable(self, "_on_map_undock_requested"))
@@ -170,41 +169,22 @@ func _on_map_navigate_to_location_requested(dest_system_id: String, dest_locatio
 		Log.add_entry("Docking failed: location is not in that system.", "SHIP")
 		return
-	var target_system_id := dest_system_id
-	if target_system_id == "":
-		target_system_id = loc_system_id
-	if target_system_id == "":
-		Log.add_entry("Docking failed: unknown destination.", "SHIP")
+	if loc_system_id == "" or loc_system_id != GameState.current_system_id:
+		Log.add_entry("Docking failed: travel to that system first.", "SHIP")
 		return
-	if target_system_id != GameState.current_system_id:
-		var path: Array = Galaxy.find_path(GameState.current_system_id, target_system_id)
-		if path.is_empty() or path.size() < 2:
-			Log.add_entry("No route from here to that system.", "SHIP")
-			return
-		var hops: int = path.size() - 1
-		Log.add_entry("Setting course to %s (%d jumps)." % [target_system_id, hops], "SHIP")
-		GameState.auto_travel(path)
-		_refresh_status()
-		_ensure_map_panel()
-		if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
-			_map_panel.call_deferred("request_refresh")
-		if GameState.current_system_id != target_system_id:
-			Log.add_entry("Auto-travel stopped before reaching destination.", "SHIP")
-			return
-	var loc_name: String = String(loc.get("name", dest_location_id))
-	Log.add_entry("Docking at %s." % loc_name, "SHIP")
-	GameState.set_current_location(dest_location_id)
+	GameState.dock_to_location(dest_location_id)
 	_refresh_status()
 	_ensure_map_panel()
 	if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
 		_map_panel.call_deferred("request_refresh")
-func _on_map_close_requested() -> void:
-	pass
+func _on_map_undock_requested() -> void:
+	GameState.undock()
+	_refresh_status()
+	_ensure_map_panel()
+	if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
+		_map_panel.call_deferred("request_refresh")

diff --git a/scripts/MapPanel.gd b/scripts/MapPanel.gd
index 2594667..d1af940 100644
--- a/scripts/MapPanel.gd
+++ b/scripts/MapPanel.gd
@@ -1,9 +1,8 @@
-# res://scripts/MapPanel.gd
 extends Control
 signal navigate_to_system_requested(dest_system_id: String)
 signal navigate_to_location_requested(dest_system_id: String, dest_location_id: String)
-signal close_requested()
+signal undock_requested()
@@ -32,9 +31,10 @@ func _ready() -> void:
 	systems_tree.item_activated.connect(_on_tree_item_activated)
 	set_course_button.pressed.connect(_on_set_course_pressed)
-	close_button.pressed.connect(_on_close_pressed)
+	close_button.pressed.connect(_on_dock_button_pressed)
 	GameState.system_changed.connect(_on_system_changed)
+	GameState.location_changed.connect(_on_location_changed)
 	visibility_changed.connect(_on_visibility_changed)
@@ -53,6 +53,7 @@ func _ready() -> void:
 	systems_tree.add_theme_constant_override("item_margin", 22)
 	systems_tree.add_theme_constant_override("h_separation", 4)
+	_refresh_dock_button_state()
@@ -66,6 +67,7 @@ func _refresh_all() -> void:
 	_did_empty_retry = false
 	_refresh_systems_list(search_box.text.strip_edges())
+	_refresh_dock_button_state()
@@ -227,6 +212,23 @@ func _refresh_systems_list(filter_text: String) -> void:
 	if systems_tree.get_root() != null and systems_tree.get_root().get_first_child() != null:
 		systems_tree.set_selected(systems_tree.get_root().get_first_child(), 0)
+
+func _on_search_text_changed(new_text: String) -> void:
+	_refresh_systems_list(new_text)
+	_refresh_dock_button_state()
+
+func _on_search_clear_pressed() -> void:
+	search_box.text = ""
+	_refresh_systems_list("")
+	_refresh_dock_button_state()
+
+func _on_dock_button_pressed() -> void:
+	if GameState.current_location_id != "":
+		info_label.text = "Undocking requested."
+		emit_signal("undock_requested")
+		return
+	...
+
+func _refresh_dock_button_state() -> void:
+	...

diff --git a/singletons/GameState.gd b/singletons/GameState.gd
index 5e346b2..dfd7c81 100644
--- a/singletons/GameState.gd
+++ b/singletons/GameState.gd
@@ -331,6 +331,51 @@ func get_travel_cost(dest_system_id: String) -> float:
 	return base_cost * multiplier
+func dock_to_location(loc_id: String) -> bool:
+	...
+func undock() -> bool:
+	...
```