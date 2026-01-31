extends Node


func _change_level(level_name: StringName) -> void:
	if self.get_child_count() > 0:
		for child in self.get_children():
			child.queue_free()

	var next_level: PackedScene = level_res_map[level_name]
	self.add_child(next_level.instantiate())


func _ready() -> void:
	Events.connect("request_change_level", _change_level)

	for level_res in level_res_resource_group.load_all():
		level_res_map[level_res.level_name] = level_res.level_scene
		



@export var level_res_resource_group: ResourceGroup

var level_res_map: Dictionary
