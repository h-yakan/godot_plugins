extends StaticBody3D
class_name GaInteractForward

## Physics bodies the interaction ray can hit, forwarding to a Node3D script (doors).

@export var target_path: NodePath = ^".."

func interact() -> void:
	var target := get_node_or_null(target_path)
	if target and target.has_method("interact"):
		target.interact()
