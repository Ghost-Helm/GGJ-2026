extends Button

var _btn_scale: Vector2
var _child_scales: Dictionary
var _has_children: bool

func _ready() -> void:
    _btn_scale = scale
    _child_scales = {}
    _has_children = false
    for child in get_children():
        if child is Control:
            _has_children = true
            _child_scales[child] = child.scale
    button_down.connect(func(): _apply_press_effect(true))
    button_up.connect(func(): _apply_press_effect(false))

func _apply_press_effect(is_pressed: bool) -> void:
    if _has_children:
        for child in _child_scales.keys():
            if not is_instance_valid(child):
                continue
            child.pivot_offset = child.size * 0.5
            child.scale = _child_scales[child] * (0.95 if is_pressed else 1.0)
    else:
        pivot_offset = size * 0.5
        scale = _btn_scale * (0.95 if is_pressed else 1.0)
    Events.emit_signal("request_play_sound", "ClickSound")
