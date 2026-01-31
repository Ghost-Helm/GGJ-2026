extends Control

# 类型，坐标，距离
@export var target_face_data: PackedVector4Array


func _ready() -> void:
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
