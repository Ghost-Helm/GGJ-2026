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


func setup(res: FaceRes, bg_texture: Texture2D, id: int):
    face_icon.texture = res.face_img
    bg.texture = bg_texture
    title.text = title_en_name[id]


func _on_mouse_entered() -> void:
    if disabled:
        return
    select_1.visible = true


func _on_mouse_exited() -> void:
    if disabled:
        return
    select_1.visible = false


func _on_pressed() -> void:
    if disabled:
        return
    select_2.visible = true


func set_interactable(is_interactable: bool) -> void:
    disabled = not is_interactable
    mouse_filter = Control.MOUSE_FILTER_STOP if is_interactable else Control.MOUSE_FILTER_IGNORE
    modulate.a = 1.0 if is_interactable else 0.5
    if not is_interactable:
        select_1.visible = false
        select_2.visible = false
