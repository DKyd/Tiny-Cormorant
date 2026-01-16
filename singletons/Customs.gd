extends Node

# chance of customs inspection by security level
var inspection_chance := {
	"low": 0.5,
	"medium": 0.3,
	"high": 0.1,
}

func run_entry_check(system_id: String) -> void:
	
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return

	var sec: String = system.get("security_level", "medium")
	var chance: float = float(inspection_chance.get(sec, 0.3))

	# roll inspection 
	if randf() > chance:
		return  # no customs check this time

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": "",
	})
	Log.add_entry("Customs at %s inspected your paperwork: %s."
		% [system.get("name", system_id), str(report.get("classification", "unknown"))])

