extends RefCounted

const TestRunner := preload("res://addons/modular_perks/pro_features/tests/test_runner.gd")


static func run() -> Dictionary:
	return TestRunner.test_draft_eligibility_respects_repeatable()
