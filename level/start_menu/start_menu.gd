extends Control

@onready var start_game_btn: Button = $StartGame

var _start_game_scale: Vector2


func _ready() -> void:
    Events.emit_signal("request_play_music", "StartBgm")
    _start_game_scale = start_game_btn.scale
    start_game_btn.button_down.connect(func(): _apply_start_game_press_effect(true))
    start_game_btn.button_up.connect(func(): _apply_start_game_press_effect(false))


func _on_start_game_pressed() -> void:
    Events.emit_signal("request_play_sound", "ClickSound")
    Events.emit_signal("request_change_level", "PreStory")


func _apply_start_game_press_effect(is_pressed: bool) -> void:
    start_game_btn.pivot_offset = start_game_btn.size * 0.5
    start_game_btn.scale = _start_game_scale * (0.95 if is_pressed else 1.0)
