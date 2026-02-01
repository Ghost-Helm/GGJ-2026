extends Control

@onready var mask_eye_btn: Button = $VBoxContainer/MaskStep/List/MaskEyeBtn
@onready var mask_eye_brow_btn: Button = $VBoxContainer/MaskStep/List/MaskEyeBrowBtn
@onready var mask_nose_btn: Button = $VBoxContainer/MaskStep/List/MaskNoseBtn
@onready var mask_mouse_btn: Button = $VBoxContainer/MaskStep/List/MaskMouseBtn

@onready var mask_list: VBoxContainer = $VBoxContainer/MaskStep/List

@export var title_icon_list: Array[Texture2D]
@onready var title_icon: Control = $Decor/TitleIcon


var record_position_list: PackedVector3Array

@export var random_face_item_pic: Array[Texture2D]

## 显示的随机五官列表

@export var face_item_btn: PackedScene
@onready var decor_list: VBoxContainer = $Decor/DecorList

@onready var face_item: Control = $People/Face/FaceItem
@onready var confirm_btn: Button = $Decor/Confirm
@onready var take_photo_btn: Button = $Decor/TakePhoto
@export var fall_texture: PackedScene
@export var initial_height: float
@export var limit_left: float
@export var limit_right: float
@export var fall_speed: float
var fall_speed_tmp: float
@export var fall_delta_second: float
@onready var dialog_text: Label = $People/Dialog/Text

var _current_second: float

func _add_texture(face_res: FaceRes) -> void:
    var fall_scene: FallMask = fall_texture.instantiate()
    face_item.add_child(fall_scene)
    fall_scene.setup(face_res)

    current_fall_scene = fall_scene
    current_face_res_type = face_res.type
    current_face_res = face_res
    fall_scene.position.y = initial_height
    is_move = true

    fall_speed_tmp = fall_speed + randi_range(0, 20)

    Events.emit_signal("request_play_sound", "ClickSound")


var current_fall_scene: FallMask
var current_face_res_type: FaceRes.FACE_TYPE
var current_face_res: FaceRes
var current_face_btn: FaceItemBtn
var is_move: bool = false
var is_fall: bool = false
var is_mask: bool = false


func _input(event: InputEvent) -> void:
    if not is_mask:
        return
    if event.is_action_pressed("mask_face_fall"):
        if is_move == true && is_fall == false:
            is_move = false
            is_fall = true
            var index: int = randi_range(0, 3)
            var sound_name: StringName
            match index:
                0: sound_name = "Fall1"
                1: sound_name = "Fall2"
                2: sound_name = "Fall3"
                3: sound_name = "Fall4"
            Events.emit_signal("request_play_sound", sound_name)
        #get_viewport().set_input_as_handled()
    if event.is_action_pressed("mask_face_accept"):
        if is_move == false && is_fall == true:
            Events.emit_signal("request_play_sound", "StickSound")
            is_move = false
            is_fall = false
            _current_second = fall_delta_second + 1
            record_position_list.append(Vector3(current_face_res_type, current_fall_scene.position.x, current_fall_scene.position.y))
            if current_face_res != null:
                dialog_text.text = current_face_res.dialog
                var texture: Texture2D = emotion_pic[current_face_res.emotion]
                head_icon.texture = texture
                # Events.emit_signal("request_play_sound", "Type")
            if current_face_btn != null:
                current_face_btn.set_interactable(false)
            is_mask = false
        #get_viewport().set_input_as_handled()

@onready var head_icon: TextureRect = $People/Dialog/HeadIcon

@export var emotion_pic: Array[Texture2D]


func _physics_process(delta: float) -> void:
    if is_move:
        var mouse_position: Vector2 = face_item.get_local_mouse_position()
        var left_limit: float = limit_left
        var right_limit: float = face_item.size.x - limit_right
        var target_position_x: float = clampf(mouse_position.x, left_limit, right_limit)
        current_fall_scene.position.x = target_position_x
    elif is_fall && _current_second > fall_delta_second:
        current_fall_scene.position.y += fall_speed_tmp
        _current_second = 0
        if current_fall_scene.position.y > out_of_area:
            is_move = false
            is_fall = false
            _current_second = fall_delta_second + 1
            is_mask = false
            current_fall_scene.queue_free()

            current_face_btn.set_interactable(false)

    _current_second += delta


@export var out_of_area: float

@export var face_res_group: ResourceGroup
@export var target_count: int

var _eye_list: Array[FaceRes]
var _eyebrow_list: Array[FaceRes]
var _nose_list: Array[FaceRes]
var _mouse_list: Array[FaceRes]

var _last_result: Array[FaceRes]

## 当前的装扮进度
var mask_step: Dictionary[FaceRes.FACE_TYPE, Button]
var cur_state: FaceRes.FACE_TYPE = FaceRes.FACE_TYPE.Eye

## 在DecorList中生成
func create_decor_show():
    var random_face_list = get_random_face_res(cur_state)

    for old_face_item in decor_list.get_children():
        old_face_item.queue_free()

    var id = 0
    for face_res in random_face_list:
        var face_tmp = face_item_btn.instantiate() as FaceItemBtn
        decor_list.add_child(face_tmp)
        face_tmp.setup(face_res, random_face_item_pic[id], id)
        id += 1
        face_tmp.pressed.connect(on_face_pressed.bind(face_res, face_tmp))

func on_face_pressed(face_res: FaceRes, face_btn: FaceItemBtn):
    if is_mask:
        return
    _add_texture(face_res)
    current_face_btn = face_btn
    is_mask = true


func get_random_face_res(type: FaceRes.FACE_TYPE) -> Array[FaceRes]:
    var target_list: Array[FaceRes]
    match type:
        FaceRes.FACE_TYPE.Eye:
            target_list = _eye_list
        FaceRes.FACE_TYPE.Eyebrow:
            target_list = _eyebrow_list
        FaceRes.FACE_TYPE.Nose:
            target_list = _nose_list
        FaceRes.FACE_TYPE.Mouse:
            target_list = _mouse_list

    var current_result: Array[FaceRes] = []
    var is_duplicate: bool = true

    while is_duplicate:
        if target_count <= 0 || target_count > target_list.size():
            print("错误：选取数量无效（≤0 或 超过原数组长度）")
            return []
        # 边界条件2：原数组中无法生成更多不重复的组（极端情况，如原数组选完所有组合）
        # 此处简化处理，若需严格避免所有历史组重复，可改用列表记录所有历史组
        var max_possible_groups = 1 # 简化版仅保证与上一组不重复，如需全历史去重可扩展
        if target_list.size() == target_count:
            max_possible_groups = 1

        # 步骤1：复制原数组，避免修改原数据
        var temp_array = target_list.duplicate()
        # 步骤2：随机抽取 pick_count 个不重复的元素（组内无重复）
        current_result.clear()
        for i in target_count:
            if temp_array.is_empty():
                break
            # 随机获取一个索引并移除该元素（避免组内重复）
            var random_index = randi() % temp_array.size()
            var picked_element = temp_array.pop_at(random_index)
            current_result.append(picked_element)

        # 步骤3：判断是否与上一组重复（排序后对比，避免 [1,3] 和 [3,1] 被误判为不同）
        _last_result.duplicate().sort()
        current_result.duplicate().sort()
        is_duplicate = (_last_result == current_result) && (_last_result.size() > 0)
        # 极端情况：无法生成新组，直接退出循环（避免死循环）
        if max_possible_groups <= 0:
            break

    # 步骤4：更新上一组记录，返回本次结果
    _last_result = current_result.duplicate()
    return current_result


func _ready() -> void:
    take_photo_btn.pressed.connect(_on_take_photo_pressed)
    _update_action_buttons()

    for face_res in face_res_group.load_all():
        match face_res.type:
            FaceRes.FACE_TYPE.Eye:
                _eye_list.append(face_res)
            FaceRes.FACE_TYPE.Eyebrow:
                _eyebrow_list.append(face_res)
            FaceRes.FACE_TYPE.Nose:
                _nose_list.append(face_res)
            FaceRes.FACE_TYPE.Mouse:
                _mouse_list.append(face_res)

    mask_step = {
        FaceRes.FACE_TYPE.Eye: mask_eye_btn,
        FaceRes.FACE_TYPE.Eyebrow: mask_eye_brow_btn,
        FaceRes.FACE_TYPE.Nose: mask_nose_btn,
        FaceRes.FACE_TYPE.Mouse: mask_mouse_btn,
    }
    create_decor_show()
    var cur_button = mask_step[cur_state] as MaskStepBtn
    cur_button.set_select(true)

    create_decor_show()


func _on_confirm_pressed() -> void:
    Events.emit_signal("request_play_sound", "NextFace")
    if cur_state == FaceRes.FACE_TYPE.size() - 1:
        return

    cur_state += 1
    update_title_icon()
    for mask_type_item: MaskStepBtn in mask_list.get_children():
        mask_type_item.set_select(false)
    create_decor_show()
    var cur_button = mask_step[cur_state] as Button
    cur_button.set_select(true)
    _update_action_buttons()


@onready var dialog: Control = $People/Dialog


func _on_take_photo_pressed() -> void:
    dialog.visible = false
    await RenderingServer.frame_post_draw
    Save.save_position_data(record_position_list)
    Save.save_image(get_viewport().get_texture().get_image())

    Events.emit_signal("request_change_level", "Passport")


func _update_action_buttons() -> void:
    var is_last: bool = cur_state == FaceRes.FACE_TYPE.size() - 1
    confirm_btn.visible = not is_last
    take_photo_btn.visible = is_last

func update_title_icon():
    for child in title_icon.get_children():
        child.queue_free()
    var icon_tmp = TextureRect.new()
    icon_tmp.texture = title_icon_list[cur_state]
    title_icon.add_child(icon_tmp)


func _on_random_pressed() -> void:
    Events.emit_signal("request_play_sound", "RandomSound")
    create_decor_show()
