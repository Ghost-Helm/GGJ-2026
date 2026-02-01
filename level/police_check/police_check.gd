extends Control

# 类型，坐标，距离
@export var target_face_data: PackedVector4Array
@onready var dialog_label: Label = $Dialog/Label
@onready var passport_photo: TextureRect = $PassPort/Photo
@onready var pass_port: Control = $PassPort
@onready var hand: Control = $Hand

var dialog_lines: Array[String] = [
    "欢迎来到澳门航空",
    "请出示你的证件",
    "让我核对你的信息"
]
var dialog_actions: Array[StringName] = [
    StringName(),
    &"on_dialog_finished",
    &"on_check_start",
]
var dialog_durations: Array[float] = [
    2.0,
    2.0,
    2.0
]

@export var check_start_pos: Vector2
@export var check_end_pos: Vector2

var _dialog_index: int = -1
var _dialog_timer: Timer


func _ready() -> void:
    var image: Image = Save.get_image()
    if image != null:
        passport_photo.texture = ImageTexture.create_from_image(image)

    _dialog_timer = Timer.new()
    _dialog_timer.one_shot = true
    add_child(_dialog_timer)
    _dialog_timer.timeout.connect(_on_dialog_timeout)
    _advance_dialog()

    var player_face_data: PackedVector3Array = Save.get_position_data()

    var target_vector4_array: PackedVector4Array = target_face_data
    var existing_vector3_array: PackedVector3Array = player_face_data

    var is_all_valid: bool = true

    var processed_targets = []
    for vec4 in target_vector4_array:
        processed_targets.append({
            "type": vec4.w,          # 类型
            "pos": Vector2(vec4.x, vec4.y),  # 2D目标坐标
            "max_distance": vec4.z,  # 距离阈值
            "original_vec4": vec4    # 保留原向量
        })
    
    # 步骤2：预处理 - 转换现有PackedVector3Array为字典数组
    var processed_existings = []
    for vec3 in existing_vector3_array:
        processed_existings.append({
            "type": vec3.x,          # 类型
            "pos": Vector2(vec3.y, vec3.z),  # 2D现有坐标
            "original_vec3": vec3    # 保留原向量
        })
    
    # 步骤3：按类型分组（处理类型重复）
    # 目标数据分组：key=类型，value=该类型下的所有预处理目标数据
    var targets_by_type = {}
    for target in processed_targets:
        var type_key = str(target["type"])  # 用字符串作为key避免类型问题
        if not targets_by_type.has(type_key):
            targets_by_type[type_key] = []
        targets_by_type[type_key].append(target)
    
    # 现有数据分组：key=类型，value=该类型下的所有预处理现有数据
    var existings_by_type = {}
    for existing in processed_existings:
        var type_key = str(existing["type"])
        if not existings_by_type.has(type_key):
            existings_by_type[type_key] = []
        existings_by_type[type_key].append(existing)
    
    # 步骤4：同类型一一匹配 + 距离验证
    var valid_matches = []  # 存储最终符合条件的匹配对
    for type_key in targets_by_type:
        # 获取当前类型下的所有目标和现有数据
        var type_targets = targets_by_type[type_key]
        var type_existings = existings_by_type.get(type_key, [])
        
        # 边界提示：同类型下目标和现有数据数量不一致
        if type_targets.size() != type_existings.size():
            is_all_valid = false
        
        # 按索引一一对应（支持重复类型，保持数组原有顺序）
        var match_count = min(type_targets.size(), type_existings.size())
        for i in range(match_count):
            var current_target = type_targets[i]
            var current_existing = type_existings[i]
            
            # 计算2D实际距离（使用Vector2的内置方法，高效且准确）
            var actual_distance = current_target["pos"].distance_to(current_existing["pos"])
            
            # 验证：实际距离 ≤ 目标定义的距离阈值
            if actual_distance > current_target["max_distance"]:
                is_all_valid = false
    
    print(is_all_valid)

func _advance_dialog() -> void:
    _dialog_index += 1
    if _dialog_index >= dialog_lines.size():
        return
    dialog_label.text = dialog_lines[_dialog_index]
    var duration: float = 2.0
    if _dialog_index < dialog_durations.size() && dialog_durations[_dialog_index] > 0.0:
        duration = dialog_durations[_dialog_index]
    _dialog_timer.start(duration)


func _on_dialog_timeout() -> void:
    _fire_dialog_action(_dialog_index)
    _advance_dialog()


func _fire_dialog_action(index: int) -> void:
    if index < dialog_actions.size():
        var method: StringName = dialog_actions[index]
        if method != StringName() && has_method(method):
            call_deferred(method)


func on_dialog_finished() -> void:
    ##写一个动画，推入护照显示
    pass_port.visible = true
    _play_passport_tween()
    
func on_check_start() -> void:
    hand.visible = true
    hand.position = check_start_pos
    
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(hand, "position", check_end_pos, 1)
    tween.tween_property(hand, "position", check_start_pos, 2)
    tween.tween_callback(func(): hand.visible = false)


func _play_passport_tween() -> void:
    var base_scale: Vector2 = pass_port.scale
    pass_port.pivot_offset = pass_port.size * 0.5
    pass_port.scale = base_scale * 1.4
    pass_port.modulate = Color(1, 1, 1, 0.0)

    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(pass_port, "scale", base_scale, 0.25)
    tween.parallel().tween_property(pass_port, "modulate", Color(1, 1, 1, 1), 0.5)
