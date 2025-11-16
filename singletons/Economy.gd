# res://singletons/Economy.gd
extends Node

# system_id -> Array<Dictionary> of price entries
var price_cache: Dictionary = {}

# Call this once somewhere (e.g. in Galaxy._ready or a main scene)
func _ready() -> void:
	randomize()


func get_local_price_for_system_id(system_id: String, commodity_id: String) -> float:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return 0.0
	return get_local_price(system, commodity_id)


func get_local_price(system: Dictionary, commodity_id: String) -> float:
	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		return 0.0

	var base_price: float = float(commodity.get("base_price", 10.0))
	var system_type: String = system.get("system_type", "industrial")
	var population: int = int(system.get("population", 1_000_000))

	var producer_types: Array = commodity.get("producer_types", []) as Array
	var consumer_types: Array = commodity.get("consumer_types", []) as Array

	var is_producer: bool = producer_types.has(system_type)
	var is_consumer: bool = consumer_types.has(system_type)

	var price: float = base_price

	# Producer worlds sell cheaper
	if is_producer:
		price *= 0.7

	# Consumer worlds buy at a premium
	if is_consumer:
		price *= 1.25

	# Population factor: up to +50% price for very big populations
	var pop_factor: float = float(population) / 20_000_000.0
	if pop_factor > 0.5:
		pop_factor = 0.5
	elif pop_factor < 0.0:
		pop_factor = 0.0

	price *= (1.0 + pop_factor)

	# Add a bit of random market noise: -10% to +10%
	var noise: float = (randf() - 0.5) * 0.2
	price *= (1.0 + noise)

	# Ensure non-zero positive price
	if price < 1.0:
		price = 1.0

	return price


func get_price_list_for_system(system_id: String) -> Array:
	# Cached entrypoint used by the rest of the game
	if price_cache.has(system_id):
		return price_cache[system_id]

	var list: Array = _generate_price_list_for_system(system_id)
	price_cache[system_id] = list
	return list


func _generate_price_list_for_system(system_id: String) -> Array:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return []

	var result: Array = []
	var ids: Array = CommodityDB.get_all_ids()

	for commodity_id_variant in ids:
		var commodity_id: String = str(commodity_id_variant)
		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		if commodity.is_empty():
			continue

		var name: String = commodity.get("name", commodity_id)
		var price: float = get_local_price(system, commodity_id)

		result.append({
			"id": commodity_id,
			"name": name,
			"price": price
		})

	return result

#------- FOR FUTURE USE WHEN TIME MECHANICS -------
func invalidate_prices_for_system(system_id: String) -> void:
	price_cache.erase(system_id)


func invalidate_all_prices() -> void:
	price_cache.clear()
