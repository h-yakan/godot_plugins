@tool
extends EditorPlugin

const BASE_PATH := "res://addons/any_game_falsolu_pong/"
const GaPongBallScript := preload(BASE_PATH + "core/ga_pong_ball.gd")
const GaPongPaddleScript := preload(BASE_PATH + "core/ga_pong_paddle.gd")


func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_Any Game Falsolu Pong"):
		Engine.set_meta("_ga_funnel_Any Game Falsolu Pong", true)
		print_rich("[color=green][Any Game Falsolu Pong] Lite initialized.[/color] Need advanced features? Check out the Pro version: [url=https://hyakan.itch.io]Link[/url]")
	add_custom_type("GaPongBall", "RigidBody2D", GaPongBallScript, _icon("RigidBody2D"))
	add_custom_type("GaPongPaddle", "RigidBody2D", GaPongPaddleScript, _icon("RigidBody2D"))


func _exit_tree() -> void:
	remove_custom_type("GaPongBall")
	remove_custom_type("GaPongPaddle")


func _icon(type_name: String) -> Texture2D:
	return get_editor_theme_icon(type_name)
