class_name PerkDraftService
extends RefCounted

enum OfferKind { PERK, GATE, REROLL }

var _registry
var _config


func _init(registry, config) -> void:
	_registry = registry
	_config = config


func get_eligible_perks(
	perk_source: Array,
	state,
	selection_mode: String
) -> Array:
	var eligible: Array = []
	for perk in perk_source:
		if perk == null:
			continue
		if selection_mode != "session_start" and bool(perk.session_start_only):
			continue
		if bool(perk.repeatable):
			eligible.append(perk)
			continue
		if state.picked_ids.has(String(perk.id)):
			continue
		if state.active_ids.has(String(perk.id)):
			continue
		eligible.append(perk)
	return eligible


func get_perk_pool_for_roll(
	unlock_score: int,
	state,
	preview_locked: bool,
	selection_mode: String
) -> Array:
	var source: Array = []
	if preview_locked:
		source = _registry.get_all()
	else:
		source = _registry.get_unlocked(unlock_score)
	return get_eligible_perks(source, state, selection_mode)


func roll_offer_kind(eligible_gates: Array) -> OfferKind:
	var r := randf()
	if r < float(_config.offer_weight_reroll):
		return OfferKind.REROLL
	if r < float(_config.offer_weight_reroll) + float(_config.offer_weight_gate) and not eligible_gates.is_empty():
		return OfferKind.GATE
	return OfferKind.PERK


func roll_one_offer_slot(
	perk_pool: Array,
	gate_pool: Array,
	reroll_allowed: bool
) -> Variant:
	if not reroll_allowed:
		var gate_share := float(_config.offer_weight_gate) / maxf(
			0.0001,
			1.0 - float(_config.offer_weight_reroll)
		)
		var r_gate := randf()
		if r_gate < gate_share and not gate_pool.is_empty():
			return _pick_random_uniform(gate_pool, 1)[0]
		if not perk_pool.is_empty():
			return _pick_random_uniform(perk_pool, 1)[0]
		return null

	match roll_offer_kind(gate_pool):
		OfferKind.REROLL:
			return {"kind": "reroll"}
		OfferKind.GATE:
			return _pick_random_uniform(gate_pool, 1)[0]
		_:
			if perk_pool.is_empty():
				if not gate_pool.is_empty():
					return _pick_random_uniform(gate_pool, 1)[0]
				return {"kind": "reroll"}
			return _pick_random_uniform(perk_pool, 1)[0]


func roll_selection_offers(
	unlock_score: int,
	state,
	count: int = 3,
	preview_locked: bool = false,
	selection_mode: String = "default"
) -> Array:
	var eligible_gates: Array = _registry.get_eligible_gates(unlock_score, state.active_ids)
	var offers: Array = []
	var reroll_in_batch := false
	var used_perk_ids: Array[String] = []

	while offers.size() < count:
		var base_pool := get_perk_pool_for_roll(unlock_score, state, preview_locked, selection_mode)
		var perk_pool: Array = []
		for perk in base_pool:
			if not used_perk_ids.has(String(perk.id)):
				perk_pool.append(perk)

		if perk_pool.is_empty() and eligible_gates.is_empty() and offers.is_empty():
			break
		if perk_pool.is_empty() and eligible_gates.is_empty() and offers.size() >= count:
			break

		var slot: Variant = roll_one_offer_slot(perk_pool, eligible_gates, not reroll_in_batch)
		if slot == null:
			break

		if slot is Dictionary and String(slot.get("kind", "")) == "reroll":
			reroll_in_batch = true
			offers.append(slot)
			continue

		if slot is Dictionary and slot.has("id") and String(slot.get("id", "")).begins_with("gate_"):
			offers.append(slot.duplicate(true))
			continue

		var perk = slot
		if perk == null:
			continue

		offers.append({
			"kind": "perk",
			"perk_id": String(perk.id),
			"perk": perk,
			"preview_only": preview_locked and bool(perk.is_locked(unlock_score)),
		})
		if not bool(perk.repeatable):
			used_perk_ids.append(String(perk.id))

	return offers


func resolve_gate(
	gate_id: String,
	unlock_score: int,
	state,
	selection_mode: String = "default"
) -> Array:
	var category: String = _registry.get_gate_category(gate_id)
	if category == "":
		return []
	var cat_pool: Array = []
	for perk in _registry.get_unlocked(unlock_score):
		if String(perk.category) != category:
			continue
		if selection_mode != "session_start" and bool(perk.session_start_only):
			continue
		if state.picked_ids.has(String(perk.id)) and not bool(perk.repeatable):
			continue
		if state.active_ids.has(String(perk.id)) and not bool(perk.repeatable):
			continue
		cat_pool.append(perk)
	return _pick_random_uniform(cat_pool, mini(3, cat_pool.size()))


func apply_pick(
	state,
	perk_id: String,
	preview_only: bool = false
) -> void:
	var normalized := String(perk_id).strip_edges()
	if normalized == "":
		return
	if not state.active_ids.has(normalized):
		state.active_ids.append(normalized)
	if preview_only:
		return
	if not state.picked_ids.has(normalized):
		state.picked_ids.append(normalized)


static func _pick_random_uniform(pool: Array, count: int) -> Array:
	if pool.is_empty() or count <= 0:
		return []
	var working := pool.duplicate()
	var picked: Array = []
	while working.size() > 0 and picked.size() < count:
		var index := randi() % working.size()
		picked.append(working[index])
		working.remove_at(index)
	return picked
