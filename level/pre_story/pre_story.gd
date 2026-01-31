extends Control


func _on_next_pressed() -> void:
	Events.emit_signal("request_change_level", "MaskFace")
