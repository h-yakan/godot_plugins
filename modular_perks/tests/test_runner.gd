extends RefCounted

const ModuleLoader := preload("res://godot_plugins/modular_perks/load.gd")


static func run_all() -> Dictionary:
	var passed := 0
	var failed := 0
	var cases: Array[Callable] = [
		test_registry_loads_sample_tres,
		test_draft_eligibility_respects_repeatable,
		test_gate_requires_minimum_category_count,
		test_effect_bus_applies_resource_bonus,
		test_run_state_roundtrip,
	]
	for test_case in cases:
		var result: Dictionary = test_case.call()
		if bool(result.get("ok", false)):
			passed += 1
		else:
			failed += 1
			push_error("FAIL: %s — %s" % [String(result.get("name", "unknown")), String(result.get("message", ""))])
	return {"passed": passed, "failed": failed}


static func _pass(name: String) -> Dictionary:
	return {"ok": true, "name": name}


static func _fail(name: String, message: String) -> Dictionary:
	return {"ok": false, "name": name, "message": message}


static func test_registry_loads_sample_tres() -> Dictionary:
	var api: Object = ModuleLoader.create_api()
	var loaded: int = api.register_pack_from_dir(ModuleLoader.sample_content_dir())
	if loaded < 5:
		return _fail("registry_loads_sample_tres", "expected >= 5 tres files, got %d" % loaded)
	if api.registry.get_perk("sample_keen_eye") == null:
		return _fail("registry_loads_sample_tres", "sample_keen_eye missing")
	return _pass("registry_loads_sample_tres")


static func test_draft_eligibility_respects_repeatable() -> Dictionary:
	var api: Object = ModuleLoader.create_api()
	ModuleLoader.register_sample_pack(api)
	var state: Object = ModuleLoader.create_run_state()
	state.active_ids.append("sample_trade_token")
	state.picked_ids.append("sample_trade_token")
	var pool: Array = api.draft.get_eligible_perks(
		api.registry.get_unlocked(api.get_unlock_score()),
		state,
		"default"
	)
	var has_repeatable := false
	for perk in pool:
		if String(perk.id) == "sample_trade_token":
			has_repeatable = true
	if not has_repeatable:
		return _fail("draft_repeatable", "repeatable perk should stay eligible")
	return _pass("draft_repeatable")


static func test_gate_requires_minimum_category_count() -> Dictionary:
	var api: Object = ModuleLoader.create_api()
	ModuleLoader.register_sample_pack(api)
	var state: Object = ModuleLoader.create_run_state()
	var gates: Array = api.registry.get_eligible_gates(api.get_unlock_score(), state.active_ids)
	if gates.is_empty():
		return _fail("gate_minimum", "expected at least one eligible gate with sample pack")
	return _pass("gate_minimum")


static func test_effect_bus_applies_resource_bonus() -> Dictionary:
	var host: Object = ModuleLoader.create_null_host()
	var api: Object = ModuleLoader.create_api(host)
	ModuleLoader.register_sample_pack(api)
	var state: Object = ModuleLoader.create_run_state()
	api.apply_pick(state, "sample_keen_eye")
	if host.resource_bonuses.is_empty():
		return _fail("effect_resource_bonus", "host did not receive resource bonus")
	if int(host.resource_bonuses[0].get("amount", 0)) != 5:
		return _fail("effect_resource_bonus", "unexpected bonus amount")
	return _pass("effect_resource_bonus")


static func test_run_state_roundtrip() -> Dictionary:
	var state: Object = ModuleLoader.create_run_state()
	state.active_ids.append("sample_keen_eye")
	state.picked_ids.append("sample_keen_eye")
	state.set_flag("session_start_done", true)
	var state_script: GDScript = load("res://godot_plugins/modular_perks/core/perk_run_state.gd")
	var restored: Object = state_script.from_dict(state.to_dict())
	if restored.active_ids != state.active_ids:
		return _fail("run_state_roundtrip", "active_ids mismatch")
	if not bool(restored.get_flag("session_start_done", false)):
		return _fail("run_state_roundtrip", "flags mismatch")
	return _pass("run_state_roundtrip")
