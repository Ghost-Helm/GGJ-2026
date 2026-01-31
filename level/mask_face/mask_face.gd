extends Control

## 显示的随机五官列表
@onready var decor_list: VBoxContainer = $MarginContainer/HBoxContainer/HBoxContainer/Decor/DecorList
@export var face_item_btn: PackedScene



@export var face_res_group: ResourceGroup
@export var target_count: int

var _hair_cut_list: Array[FaceRes]
var _eyebrow_list: Array[FaceRes]
var _mouse_list: Array[FaceRes]
var _other_list: Array[FaceRes]

var _last_result: Array[FaceRes]

## 当前的装扮进度
var cur_state: FaceRes.FACE_TYPE = FaceRes.FACE_TYPE.Eyebrow



## 在DecorList中生成
func create_decor_show():
	var random_face_list = get_random_face_res(cur_state)
	
	for old_face_item in decor_list.get_children():
		old_face_item.queue_free()
	
	for face_res in random_face_list:
		var face_tmp = face_item_btn.instantiate() as FaceItemBtn
		decor_list.add_child(face_tmp)
		face_tmp.setup(face_res)




func get_random_face_res(type: FaceRes.FACE_TYPE) -> Array[FaceRes]:
	var target_list: Array[FaceRes]
	match type:
		FaceRes.FACE_TYPE.HairCut:
			target_list = _hair_cut_list
		FaceRes.FACE_TYPE.Eyebrow:
			target_list = _eyebrow_list
		FaceRes.FACE_TYPE.Mouse:
			target_list = _mouse_list
		FaceRes.FACE_TYPE.Other:
			target_list = _other_list

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
	for face_res in face_res_group.load_all():
		match face_res.type:
			FaceRes.FACE_TYPE.HairCut:
				_hair_cut_list.append(face_res)
			FaceRes.FACE_TYPE.Eyebrow:
				_eyebrow_list.append(face_res)
			FaceRes.FACE_TYPE.Mouse:
				_mouse_list.append(face_res)
			FaceRes.FACE_TYPE.Other:
				_other_list.append(face_res)
	create_decor_show()
