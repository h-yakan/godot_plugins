extends RefCounted
class_name GaSkillCatalog

## Helper for registering bundled sample skill definitions at runtime.

const SAMPLE_DEFINITIONS_DIR := "res://addons/any_game_skill_system/pro_features/content/sample"


static func register_sample_skills(controller: GaSkillController) -> int:
	if controller == null:
		return 0
	return controller.register_definitions_from_directory(SAMPLE_DEFINITIONS_DIR)


static func load_sample_skill(
	host: GaSkillHost,
	skill_id: String,
	container_path: NodePath = NodePath("Slots")
) -> GaSkill:
	if host == null:
		return null
	return host.load_skill(skill_id, container_path, SAMPLE_DEFINITIONS_DIR)
