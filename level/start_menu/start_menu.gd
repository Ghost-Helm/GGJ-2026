extends Control
@onready var start_game: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/StartGame
@onready var about_us: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/AboutUs
@onready var exit_game: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/ExitGame




func _on_start_game_pressed() -> void:
	Events.emit_signal("request_change_level", "PreStory")




func _on_about_us_pressed() -> void:
	pass # Replace with function body.




func _on_exit_game_pressed() -> void:
	pass # Replace with function body.
