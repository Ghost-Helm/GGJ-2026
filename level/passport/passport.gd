extends Control
@onready var sign_name_img: TextureRect = $Control/SignNameImg
@onready var change_timer: Timer = $ChangeTimer
@onready var sign_name_btn: Button = $Control/SignName
@onready var photo: TextureRect = $Control/Photo

var _sign_name_base_scale: Vector2
var _sign_name_base_modulate: Color




func _on_sign_name_pressed() -> void:
    sign_name_img.visible = true
    _play_stamp_tween()
    sign_name_btn.visible = false
    change_timer.start()
    

func _ready() -> void:
    var image:Image = Save.get_image()
    var texture_photo:Texture2D = ImageTexture.create_from_image(image)
    photo.texture = texture_photo
    photo.scale = Vector2(0.2, 0.2)
    _sign_name_base_scale = sign_name_img.scale
    _sign_name_base_modulate = sign_name_img.modulate


func _play_stamp_tween() -> void:
    var start_scale: Vector2 = _sign_name_base_scale * 1.4
    sign_name_img.pivot_offset = sign_name_img.size * 0.5
    sign_name_img.scale = start_scale
    sign_name_img.modulate = Color(
        _sign_name_base_modulate.r,
        _sign_name_base_modulate.g,
        _sign_name_base_modulate.b,
        0.0
    )
    Events.emit_signal("request_play_sound", "FakeSignSound")
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(sign_name_img, "scale", _sign_name_base_scale, 0.25)
    tween.parallel().tween_property(sign_name_img, "modulate", _sign_name_base_modulate, 0.2)
    Events.emit_signal("request_play_sound", "SignSound")



func _on_change_timer_timeout() -> void:
    Events.emit_signal("request_change_level", "PoliceCheck")
