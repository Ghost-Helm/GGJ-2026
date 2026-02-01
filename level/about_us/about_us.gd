extends Control




func _on_button_pressed() -> void:
    Events.emit_signal("request_change_level", "StartMenu")
