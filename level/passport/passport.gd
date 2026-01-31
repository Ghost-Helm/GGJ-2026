extends Control
@onready var sign_name_img: ColorRect = $Control/SignNameImg
@onready var change_timer: Timer = $ChangeTimer
@onready var sign_name_btn: Button = $Control/SignName




func _on_sign_name_pressed() -> void:
	sign_name_img.visible = true
	sign_name_btn.visible = false
	change_timer.start()
	



func _on_change_timer_timeout() -> void:
	Events.emit_signal("request_change_level", "PoliceCheck")
