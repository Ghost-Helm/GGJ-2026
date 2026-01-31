extends Node


func _ready() -> void:
    Events.emit_signal("request_change_level", "StartMenu")
