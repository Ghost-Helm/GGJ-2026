extends Button
class_name FaceItemBtn

@onready var face_icon: TextureRect = $FaceIcon
@onready var bg: TextureRect = $Bg
@onready var select_1: TextureRect = $Select1
@onready var select_2: TextureRect = $Select2
@onready var title: Label = $Title

var title_en_name = [
	"one",
	"two",
	"three"
]



func setup(res:FaceRes, bg_texture:Texture2D, id:int):
	face_icon.texture = res.face_img
	bg.texture = bg_texture
	title.text = title_en_name[id]
	

func _on_mouse_entered() -> void:
	select_1.visible = true
	

func _on_mouse_exited() -> void:
	select_1.visible = false


func _on_pressed() -> void:
	select_2.visible = true
