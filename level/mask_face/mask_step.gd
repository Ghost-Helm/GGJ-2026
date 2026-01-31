extends Button
class_name MaskStepBtn

@onready var normal_bg: TextureRect = $NormalBg
@onready var normal: TextureRect = $Normal

@onready var select_bg: TextureRect = $SelectBg
@onready var select: TextureRect = $Select

func _ready() -> void:
    _toggle_btn_state(true)
    
func set_select(is_select:bool):
    _toggle_btn_state(not is_select)
    

func _toggle_btn_state(is_normal:bool):
    normal.visible = is_normal
    normal_bg.visible = is_normal
    select_bg.visible = not is_normal
    select.visible = not is_normal
