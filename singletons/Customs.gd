#C res://singletons/Customs.gd
extends Node

# chance of customs inspection by pressure bucket
var inspection_chance := {
	"Low": 0.1,
	"Elevated": 0.3,
	"High": 0.5,
}

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
	Log.add_entry("Customs at %s inspected your paperwork: %s."
		% [system.get("name", system_id), str(report.get("classification", "unknown"))])
