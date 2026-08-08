class_name PerkFlow
extends RefCounted

const SELECTION_SCENE := preload("res://godot_plugins/modular_perks/ui/perk_selection_screen.tscn")
const TARGET_SCENE := preload("res://godot_plugins/modular_perks/ui/perk_target_pick_ui.tscn")


static func await_selection(
	tree: SceneTree,
	api,
	state,
	selection_mode: String = "default",
	preview_locked: bool = false
) -> Dictionary:
	var offers := api.roll_offers(state, 3, preview_locked, selection_mode)
	if offers.is_empty():
		return {}
	var layer := CanvasLayer.new()
	tree.root.add_child(layer)
	var screen := SELECTION_SCENE.instantiate()
	layer.add_child(screen)
	screen.configure(api, state)
	screen.present_offers(offers, selection_mode, preview_locked)
	var picked: Array = await screen.selection_completed
	layer.queue_free()
	if picked.is_empty() or String(picked[0]) == "":
		return {}
	return {
		"perk_id": String(picked[0]),
		"offer": picked[1] as Dictionary,
	}


static func await_target_pick(
	tree: SceneTree,
	api,
	perk_id: String,
	context: Dictionary = {}
) -> Dictionary:
	var merged_context := context.duplicate(true)
	merged_context["perk_id"] = perk_id
	var entities: Array = api.host.list_target_entities(merged_context)
	var layer := CanvasLayer.new()
	tree.root.add_child(layer)
	var screen := TARGET_SCENE.instantiate()
	layer.add_child(screen)
	var definition = api.registry.get_perk(perk_id)
	var title := api.get_localized_name(definition) if definition != null else "Choose a target"
	screen.present(title, entities, merged_context)
	var finished: Array = await screen.flow_finished
	layer.queue_free()
	if not bool(finished[0]):
		return {}
	return (finished[1] as Dictionary).duplicate(true)


static func await_option_pick(
	tree: SceneTree,
	api,
	perk_id: String,
	context: Dictionary = {}
) -> Dictionary:
	var merged_context := context.duplicate(true)
	merged_context["perk_id"] = perk_id
	var options: Array = api.host.list_option_choices(merged_context)
	var layer := CanvasLayer.new()
	tree.root.add_child(layer)
	var screen := TARGET_SCENE.instantiate()
	layer.add_child(screen)
	var definition = api.registry.get_perk(perk_id)
	var title := api.get_localized_name(definition) if definition != null else "Choose an option"
	var entities: Array = []
	for option in options:
		entities.append({
			"id": String(option.get("id", "")),
			"label": String(option.get("label", option.get("id", "Option"))),
		})
	screen.present(title, entities, merged_context)
	var finished: Array = await screen.flow_finished
	layer.queue_free()
	if not bool(finished[0]):
		return {}
	var result := (finished[1] as Dictionary).duplicate(true)
	result["option_id"] = String(result.get("entity_id", ""))
	return result


static func apply_pick_with_flows(
	tree: SceneTree,
	api,
	state,
	perk_id: String,
	offer: Dictionary = {},
	base_context: Dictionary = {}
) -> bool:
	var context := base_context.duplicate(true)
	if bool(api.requires_target_pick(perk_id)):
		var target_context := await await_target_pick(tree, api, perk_id, context)
		if target_context.is_empty():
			return false
		context.merge(target_context, true)
	elif bool(api.requires_option_pick(perk_id)):
		var option_context := await await_option_pick(tree, api, perk_id, context)
		if option_context.is_empty():
			return false
		context.merge(option_context, true)
	var preview_only := bool(offer.get("preview_only", false))
	api.apply_pick(state, perk_id, preview_only, context)
	return true
