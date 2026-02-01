extends Control

# 类型，坐标，距离
@export var target_face_data: PackedVector4Array
@onready var dialog_label: Label = $Dialog/Label
@onready var passport_photo: TextureRect = $PassPort/Photo
@onready var pass_port: Control = $PassPort
@onready var hand: Control = $Hand
@onready var police_happy: TextureRect = $Police/Happy
@onready var police_scare: TextureRect = $Police/Scare
@onready var police_smile: TextureRect = $Police/Smile
@onready var police_yell: TextureRect = $Police/Yell

## 所有的表情
@onready var happy: TextureRect = $Police/Happy
@onready var scare: TextureRect = $Police/Scare
@onready var smile: TextureRect = $Police/Smile
@onready var yell: TextureRect = $Police/Yell

@onready var real_photo: TextureRect = $RealPhoto


signal dialog_pack_finished(pack_id: String)


var _pack_a_lines: Array[String] = [
    "欢迎来到澳门航空",
    "请出示你的证件",
    "让我核对你的信息"
]
var _pack_a_actions: Array[StringName] = [
    StringName(),
    &"on_dialog_finished",
    &"on_check_start",
]
var _pack_a_durations: Array[float] = [
    2.0,
    2.0,
    2.0
]

var dialog_lines: Array[String] = []
var dialog_actions: Array[StringName] = []
var dialog_durations: Array[float] = []

## 成功情况下播放的内容
@export var dialog_pack_b_lines: Array[String] = [
    "姓名、年龄、照片......",
    "照片跟您不太相似",
    "不过我懂，总会美颜照片嘛",
    "让我再看看，没什么问题",
    "欢迎来到澳门星",
    "祝您度过一段毕生难忘的时光！"
]
@export var dialog_pack_b_actions: Array[StringName] = [
    StringName(),
    StringName(),
    &"on_check_ok",
    StringName(),
    StringName(),
    &"on_happy_end",
]
@export var dialog_pack_b_durations: Array[float] = [
    2.0,
    2.0,
    2.0
]

@export var dialog_pack_c_lines: Array[String] = [
    "姓名、年龄、照片......",
    "照片跟您不太相似",
    "喂！你这完全不对吧!",
    "这根本不是澳门星人的样子!",
    "保安！！这里有异星人！！！"
]
@export var dialog_pack_c_actions: Array[StringName] = [
    StringName(),
    StringName(),
    &"on_check_wrong",
    StringName(),
    &"on_story_bad",
]
@export var dialog_pack_c_durations: Array[float] = [
    2.0,
    2.0,
    2.0,
    2.0,
    2.0
]

@export var dialog_pack_d_lines: Array[String] = []
@export var dialog_pack_d_actions: Array[StringName] = []
@export var dialog_pack_d_durations: Array[float] = []

@export var check_start_pos: Vector2
@export var check_end_pos: Vector2

var _dialog_index: int = -1
var _dialog_timer: Timer
var _type_timer: Timer
var _type_line: String = ""
var _type_pos: int = 0
var _dialog_duration_pending: float = 0.0
var _current_pack_id: String = ""
var _flow_queue: Array[String] = []
var _scare_shake_tween: Tween
var _scare_base_pos: Vector2

@export var type_char_interval: float = 0.05

enum PoliceMood {Happy, Scare, Smile, Yell}
const PACK_A := "packA"
const PACK_B := "packB"
const PACK_C := "packC"
const PACK_D := "packD"


func _ready() -> void:
    var image: Image = Save.get_image()
    if image != null:
        passport_photo.texture = ImageTexture.create_from_image(image)

    _dialog_timer = Timer.new()
    _dialog_timer.one_shot = true
    add_child(_dialog_timer)
    _dialog_timer.timeout.connect(_on_dialog_timeout)

    _type_timer = Timer.new()
    _type_timer.one_shot = false
    add_child(_type_timer)
    _type_timer.timeout.connect(_on_type_tick)
    if not dialog_pack_finished.is_connected(_on_dialog_pack_finished):
        dialog_pack_finished.connect(_on_dialog_pack_finished)

    _scare_base_pos = police_scare.position

    var player_face_data: PackedVector3Array = Save.get_position_data()

    var target_vector4_array: PackedVector4Array = target_face_data
    var existing_vector3_array: PackedVector3Array = player_face_data

    var is_all_valid: bool = true

    if existing_vector3_array.is_empty():
        is_all_valid = false
    else:
        var processed_targets = []
        for vec4 in target_vector4_array:
            processed_targets.append({
                "type": vec4.w, # 类型
                "pos": Vector2(vec4.x, vec4.y), # 2D目标坐标
                "max_distance": vec4.z, # 距离阈值
                "original_vec4": vec4 # 保留原向量
            })

        # 步骤2：预处理 - 转换现有PackedVector3Array为字典数组
        var processed_existings = []
        for vec3 in existing_vector3_array:
            processed_existings.append({
                "type": vec3.x, # 类型
                "pos": Vector2(vec3.y, vec3.z), # 2D现有坐标
                "original_vec3": vec3 # 保留原向量
            })

        # 步骤3：按类型分组（处理类型重复）
        # 目标数据分组：key=类型，value=该类型下的所有预处理目标数据
        var targets_by_type = {}
        for target in processed_targets:
            var type_key = str(target["type"]) # 用字符串作为key避免类型问题
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
        var valid_matches = [] # 存储最终符合条件的匹配对
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
    play_full_flow(is_all_valid)

func _advance_dialog() -> void:
    _dialog_index += 1
    if _dialog_index >= dialog_lines.size():
        dialog_pack_finished.emit(_current_pack_id)
        return
    _type_line = dialog_lines[_dialog_index]
    _type_pos = 0
    dialog_label.text = ""
    _type_timer.start(type_char_interval)

    var duration: float = 2.0
    if _dialog_index < dialog_durations.size() && dialog_durations[_dialog_index] > 0.0:
        duration = dialog_durations[_dialog_index]
    _dialog_duration_pending = duration


func _on_dialog_timeout() -> void:
    _fire_dialog_action(_dialog_index)
    _advance_dialog()


func _on_type_tick() -> void:
    if _type_pos >= _type_line.length():
        _type_timer.stop()
        _dialog_timer.start(_dialog_duration_pending)
        return
    _type_pos += 1
    dialog_label.text = _type_line.substr(0, _type_pos)


func _fire_dialog_action(index: int) -> void:
    if index < dialog_actions.size():
        var method: StringName = dialog_actions[index]
        if method != StringName() && has_method(method):
            call_deferred(method)


func on_dialog_finished() -> void:
    ##写一个动画，推入护照显示
    pass_port.visible = true
    Events.emit_signal("request_play_sound", "Passport")
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
    
    await tween.finished
    real_photo.visible = true


func set_police_mood(mood: PoliceMood) -> void:
    police_happy.visible = false
    police_scare.visible = false
    police_smile.visible = false
    police_yell.visible = false
    _stop_scare_shake()

    match mood:
        PoliceMood.Happy:
            police_happy.visible = true
        PoliceMood.Scare:
            police_scare.visible = true
            _start_scare_shake()
        PoliceMood.Smile:
            police_smile.visible = true
        PoliceMood.Yell:
            police_yell.visible = true

func _start_scare_shake() -> void:
    _stop_scare_shake()
    police_scare.position = _scare_base_pos
    _scare_shake_tween = create_tween()
    _scare_shake_tween.set_loops()
    _scare_shake_tween.set_trans(Tween.TRANS_SINE)
    _scare_shake_tween.set_ease(Tween.EASE_IN_OUT)
    _scare_shake_tween.tween_property(police_scare, "position", _scare_base_pos + Vector2(6, 0), 0.04)
    _scare_shake_tween.tween_property(police_scare, "position", _scare_base_pos + Vector2(-6, 0), 0.04)
    _scare_shake_tween.tween_property(police_scare, "position", _scare_base_pos + Vector2(0, 6), 0.04)
    _scare_shake_tween.tween_property(police_scare, "position", _scare_base_pos + Vector2(0, -6), 0.04)

func _stop_scare_shake() -> void:
    if _scare_shake_tween != null:
        _scare_shake_tween.kill()
        _scare_shake_tween = null
    police_scare.position = _scare_base_pos

func play_full_flow(is_success: bool) -> void:
    _flow_queue.clear()
    _flow_queue.append(PACK_A)
    _flow_queue.append(PACK_B if is_success else PACK_C)
    _flow_queue.append(PACK_D)
    _play_next_pack()

func _play_next_pack() -> void:
    if _flow_queue.is_empty():
        return
    var pack_id = _flow_queue.pop_front()
    _play_dialog_pack(pack_id)

func _play_dialog_pack(pack_id: String) -> void:
    var lines: Array[String] = []
    var actions: Array[StringName] = []
    var durations: Array[float] = []

    match pack_id:
        PACK_A:
            lines = _pack_a_lines
            actions = _pack_a_actions
            durations = _pack_a_durations
        PACK_B:
            lines = dialog_pack_b_lines
            actions = dialog_pack_b_actions
            durations = dialog_pack_b_durations
        PACK_C:
            lines = dialog_pack_c_lines
            actions = dialog_pack_c_actions
            durations = dialog_pack_c_durations
        PACK_D:
            lines = dialog_pack_d_lines
            actions = dialog_pack_d_actions
            durations = dialog_pack_d_durations
        _:
            dialog_pack_finished.emit(pack_id)
            return

    lines = lines.duplicate()
    actions = actions.duplicate()
    durations = durations.duplicate()

    if durations.size() != lines.size():
        durations.clear()
        durations.resize(lines.size())
        for i in range(lines.size()):
            durations[i] = 2.0

    if actions.size() < lines.size():
        actions.resize(lines.size())

    dialog_lines = lines
    dialog_actions = actions
    dialog_durations = durations

    _current_pack_id = pack_id
    _dialog_index = -1
    _advance_dialog()

func _on_dialog_pack_finished(_pack_id: String) -> void:
    _play_next_pack()
    

func on_check_ok():
    set_police_mood(PoliceMood.Happy)
    
func on_check_wrong():
    set_police_mood(PoliceMood.Scare)
    
    
    
## 游戏失败，被遣返
func on_story_bad():
    Events.emit_signal("request_change_level", "BadEnd")
    
func on_happy_end():
    Events.emit_signal("request_change_level", "HappyEnd")
