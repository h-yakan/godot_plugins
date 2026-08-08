extends SceneTree

const ModuleLoader := preload("res://godot_plugins/modular_perks/load.gd")
const TestRunner := preload("res://godot_plugins/modular_perks/tests/test_runner.gd")


func _init() -> void:
	var summary: Dictionary = TestRunner.run_all()
	print("Modular Perks tests passed=%s failed=%s" % [summary.passed, summary.failed])
	quit(1 if int(summary.failed) > 0 else 0)
