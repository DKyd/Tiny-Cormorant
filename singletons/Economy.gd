# res://singletons/Economy.gd
extends Node

# system_id -> Array<Dictionary> of price entries
var price_cache: Dictionary = {}

func get_local_price_for_system_id(system_id: String, commodity_id: String) -> float:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return 0.0
	return get_local_price_at(system_id, system, commodity_id, GameState.time_tick, "legal")

func quote_sale_price(
	commodity_id: String,
	qty: int,
	system_id: String,
	location_id: String,
	market_kind: String
) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
		"base_unit_price": 0.0,
		"adjustments": [],
		"final_unit_price": 0.0,
		"total_price": 0.0,
	}

	if commodity_id == "" or qty <= 0:
		result.error = "Invalid commodity or quantity."
		return result

	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		result.error = "No market available."
		return result

	var base_unit_price: float = get_local_price_at(
		system_id,
		system,
		commodity_id,
		GameState.time_tick,
		market_kind
	)
	if base_unit_price <= 0.0:
		result.error = "No market price available."
		return result

	var adjustments: Array = []
	var final_unit_price: float = base_unit_price

	result.ok = true
	result.base_unit_price = base_unit_price
	result.adjustments = adjustments
	result.final_unit_price = final_unit_price
	result.total_price = final_unit_price * float(qty)
	return result


func get_local_price(system_id: String, system: Dictionary, commodity_id: String) -> float:
	return get_local_price_at(system_id, system, commodity_id, GameState.time_tick, "legal")


func get_local_price_at(
	system_id: String,
	system: Dictionary,
	commodity_id: String,
	tick: int,
	market_kind: String
) -> float:
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

	var normalized_kind: String = _normalize_market_kind(market_kind)

	# Add deterministic market noise: -10% to +10%
	var noise: float = _get_deterministic_noise(system_id, commodity_id, tick, normalized_kind)
	price *= (1.0 + noise)

	if normalized_kind == "black":
		price *= 1.1

	# Ensure non-zero positive price
	if price < 1.0:
		price = 1.0

	return price


func get_price_list_for_system(system_id: String) -> Array:
	return get_price_list_for_system_at(system_id, GameState.time_tick, "legal")


func get_price_list_for_system_at(system_id: String, tick: int, market_kind: String) -> Array:
	var normalized_kind: String = _normalize_market_kind(market_kind)
	var cache_key: String = _get_cache_key(system_id, tick, normalized_kind)

	if price_cache.has(cache_key):
		return price_cache[cache_key]

	var list: Array = _generate_price_list_for_system_at(system_id, tick, normalized_kind)
	price_cache[cache_key] = list
	return list


func _generate_price_list_for_system_at(system_id: String, tick: int, market_kind: String) -> Array:
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
		var price: float = get_local_price_at(system_id, system, commodity_id, tick, market_kind)

		result.append({
			"id": commodity_id,
			"name": name,
			"price": price
		})

	return result


func get_price_list_text_for_system_at(system_id: String, tick: int, market_kind: String) -> String:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return ""

	var normalized_kind: String = _normalize_market_kind(market_kind)
	var system_name: String = String(system.get("name", system_id))

	var lines: Array = []
	lines.append("Market Prices - %s (%s)" % [system_name, system_id])
	lines.append("Tick: %d  Market: %s" % [tick, normalized_kind])
	lines.append("Commodity | Price")

	var price_list: Array = get_price_list_for_system_at(system_id, tick, normalized_kind)
	price_list.sort_custom(Callable(self, "_sort_price_entries_by_name"))

	for entry_variant in price_list:
		var entry: Dictionary = entry_variant
		var name: String = String(entry.get("name", "???"))
		var price: float = float(entry.get("price", 0.0))
		lines.append("%s | %.0f" % [name, price])

	return "\n".join(lines)

#------- FOR FUTURE USE WHEN TIME MECHANICS -------
func invalidate_prices_for_system(system_id: String) -> void:
	price_cache.erase(system_id)


func invalidate_all_prices() -> void:
	price_cache.clear()


func _sort_price_entries_by_name(a_variant, b_variant) -> bool:
	if not (a_variant is Dictionary) or not (b_variant is Dictionary):
		return false

	var a: Dictionary = a_variant
	var b: Dictionary = b_variant
	var name_a: String = String(a.get("name", ""))
	var name_b: String = String(b.get("name", ""))
	return name_a < name_b


# FNV-1a 32-bit hash for deterministic pseudo-randomness from stable inputs.
# This is not cryptographic; it is used for procedural determinism only.
func _fnv1a_32(value: String) -> int:
	var hash: int = 0x811c9dc5
	var prime: int = 0x01000193
	var bytes: PackedByteArray = value.to_utf8_buffer()

	for b in bytes:
		hash ^= int(b)
		hash = int((hash * prime) & 0xffffffff)

	return hash

func _normalize_market_kind(market_kind: String) -> String:
	# Only two supported kinds for now; default to legal for safety.
	if market_kind == "black" or market_kind == GameState.MARKET_KIND_BLACK_MARKET:
		return "black"
	return "legal"


func get_black_market_offers_for_system(system_id: String) -> Array:
	return get_price_list_for_system_at(system_id, GameState.time_tick, GameState.MARKET_KIND_BLACK_MARKET)


func _get_cache_key(system_id: String, tick: int, market_kind: String) -> String:
	# Cache is keyed by system + tick + market kind.
	# Assumes system_id does not contain '|'.
	return "%s|%d|%s" % [system_id, tick, market_kind]


func _get_deterministic_noise(system_id: String, commodity_id: String, tick: int, market_kind: String) -> float:
	# Deterministic “random-looking” noise in range [-0.1, +0.1]
	# derived from stable inputs. Not dependent on RNG or call order.
	var key: String = "%s|%s|%d|%s" % [system_id, commodity_id, tick, market_kind]
	var hash: int = _fnv1a_32(key)
	var unit: float = float(hash & 0x7fffffff) / float(0x7fffffff) # [0, 1]
	return (unit - 0.5) * 0.2
