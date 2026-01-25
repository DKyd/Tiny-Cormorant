#C res://singletons/Customs.gd
extends Node

# chance of customs inspection by pressure bucket
var inspection_chance := {
	"Low": 0.1,
	"Elevated": 0.3,
	"High": 0.5,
}

func _format_location_label(system_id: String, location_id: String) -> String:
	var system: Dictionary = Galaxy.get_system(system_id)
	var location: Dictionary = Galaxy.get_location(location_id)
	var system_name: String = String(system.get("name", system_id))
	var location_name: String = String(location.get("name", location_id))
	if system_name == "":
		system_name = system_id
	if location_name == "":
		location_name = location_id
	if system_name == "" and location_name == "":
		return "unknown location"
	if system_name == "":
		return location_name
	if location_name == "":
		return system_name
	return "%s (%s)" % [location_name, system_name]


func _log_inspection(action_label: String, system_id: String, location_id: String, report: Dictionary) -> void:
	var classification: String = String(report.get("classification", "")).strip_edges()
	if classification == "":
		classification = "unknown"
	var location_label: String = _format_location_label(system_id, location_id)
	Log.add_entry(
		"CUSTOMS: %s inspection at %s: %s."
			% [action_label, location_label, classification],
		"CUSTOMS"
	)


func run_sale_check(system_id: String, location_id: String) -> void:
	if system_id == "" or location_id == "":
		return
	if Galaxy.get_system(system_id).is_empty():
		return
	if Galaxy.get_location(location_id).is_empty():
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))
	if not GameState.roll_customs_inspection(system_id, location_id, "SELL_CARGO_LEGAL", chance):
		return

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "SELL_CARGO_LEGAL",
	})
	_log_inspection("Sale", system_id, location_id, report)

func run_departure_check(system_id: String, location_id: String) -> void:
	if system_id == "" or location_id == "":
		return
	if Galaxy.get_system(system_id).is_empty():
		return
	if Galaxy.get_location(location_id).is_empty():
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))
	if not GameState.roll_customs_inspection(system_id, location_id, "PORT_DEPARTURE_CLEARANCE", chance):
		return

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "PORT_DEPARTURE_CLEARANCE",
	})
	_log_inspection("Departure clearance", system_id, location_id, report)

func run_entry_check(system_id: String, location_id: String = "") -> void:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return
	location_id = GameState.get_entry_customs_location_id(system_id)
	if location_id == "":
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))

	# roll inspection 
	if not GameState.roll_customs_inspection(system_id, location_id, "ENTRY_CLEARANCE", chance):
		return  # no customs check this time

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "ENTRY_CLEARANCE",
	})
	_log_inspection("Entry clearance", system_id, location_id, report)
