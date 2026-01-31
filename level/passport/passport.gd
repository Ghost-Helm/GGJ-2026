extends Control
@onready var sign_name_img: ColorRect = $Control/SignNameImg
@onready var change_timer: Timer = $ChangeTimer
@onready var sign_name_btn: Button = $Control/SignName
@onready var photo: TextureRect = $Control/Photo




func _on_sign_name_pressed() -> void:
    sign_name_img.visible = true
    sign_name_btn.visible = false
    change_timer.start()
    

func _ready() -> void:
    var image:Image = Save.get_image()
    var texture_photo:Texture2D = ImageTexture.create_from_image(image)
    photo.texture = texture_photo
    photo.scale = Vector2(0.3, 0.3)




func _on_change_timer_timeout() -> void:
    Events.emit_signal("request_change_level", "PoliceCheck")
