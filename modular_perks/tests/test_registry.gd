extends RefCounted

const TestRunner := preload("res://godot_plugins/modular_perks/tests/test_runner.gd")


static func run() -> Dictionary:
	return TestRunner.test_registry_loads_sample_tres()
