extends Control

@export var play_order: Array[NodePath] = []
@export var appear_duration: float = 0.45
@export var hold_duration: float = 0.05
@export var delay_between: float = 1

var _play_nodes: Array[TextureRect] = []


func _ready() -> void:
    _build_play_list()
    _prepare_nodes()
    _play_sequence()
    Events.emit_signal("request_play_sound", "HappyEndMusic")


func _build_play_list() -> void:
    _play_nodes.clear()
    if play_order.size() > 0:
        for path in play_order:
            var node := get_node_or_null(path)
            if node is TextureRect:
                _play_nodes.append(node)
    else:
        for child in get_children():
            if child is TextureRect and child.name != "Bg":
                _play_nodes.append(child)


func _prepare_nodes() -> void:
    for node in _play_nodes:
        node.visible = true
        node.modulate = Color(1, 1, 1, 0)


func _play_sequence() -> void:
    _run_sequence()


func _run_sequence() -> void:
    for node in _play_nodes:
        await _play_one(node)
        if delay_between > 0.0:
            await get_tree().create_timer(delay_between).timeout


func _play_one(node: TextureRect) -> void:
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(node, "modulate", Color(1, 1, 1, 1), appear_duration)
    tween.tween_interval(hold_duration)
    await tween.finished
