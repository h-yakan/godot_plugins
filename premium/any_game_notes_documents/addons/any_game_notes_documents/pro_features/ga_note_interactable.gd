extends StaticBody3D
class_name GaNoteInteractable

const _EventBus := preload("res://addons/any_game_notes_documents/core/ga_event_bus_client.gd")

@export var note_data: GaNoteData
@export var mesh_path: NodePath

func _ready() -> void:
	if note_data and note_data.note_image and not mesh_path.is_empty():
		var mesh_inst: MeshInstance3D = get_node_or_null(mesh_path)
		if mesh_inst and mesh_inst.mesh:
			var mat := mesh_inst.get_active_material(0)
			if mat is StandardMaterial3D:
				(mat as StandardMaterial3D).albedo_texture = note_data.note_image

func interact() -> void:
	if note_data:
		_EventBus.emit(self, &"show_note", [note_data.note_content])
