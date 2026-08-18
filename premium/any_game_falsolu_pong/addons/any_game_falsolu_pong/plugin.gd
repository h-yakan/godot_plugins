@tool
extends EditorPlugin

const BASE_PATH := "res://addons/any_game_falsolu_pong/"
const GaPongBallScript := preload(BASE_PATH + "core/ga_pong_ball.gd")
const GaPongPaddleScript := preload(BASE_PATH + "core/ga_pong_paddle.gd")
const GaPongCourtScript := preload(BASE_PATH + "pro_features/ga_pong_court.gd")


func _enter_tree() -> void:
	add_custom_type("GaPongBall", "RigidBody2D", GaPongBallScript, _icon("RigidBody2D"))
	add_custom_type("GaPongPaddle", "RigidBody2D", GaPongPaddleScript, _icon("RigidBody2D"))
	add_custom_type("GaPongCourt", "Node2D", GaPongCourtScript, _icon("Node2D"))


func _exit_tree() -> void:
	remove_custom_type("GaPongBall")
	remove_custom_type("GaPongPaddle")
	remove_custom_type("GaPongCourt")


func _icon(type_name: String) -> Texture2D:
	return get_editor_theme_icon(type_name)
