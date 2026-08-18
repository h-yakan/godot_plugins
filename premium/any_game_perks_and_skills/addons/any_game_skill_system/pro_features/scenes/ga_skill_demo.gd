extends Node2D

## Demo root: provides sample mana pool and wires the cost provider.

var mana: float = 100.0


func _ready() -> void:
	var controller: GaSkillController = $GaSkillHost/GaSkillController
	controller.caster_path = NodePath("..")
	controller.set_cost_provider(GaSimpleManaProvider.new())
