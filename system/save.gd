extends Node

var position_data: PackedVector2Array
var image: Image


func _save_position_data(data: PackedVector2Array) -> void:
    position_data = data


func _save_image(target_image: Image) -> void:
    image = target_image
    image.save_png("user://uncut.png")
    var cut_image: Image = image.get_region(Rect2i(31, 40, 800, 1000))
    cut_image.save_png("user://cut.png")
    image = cut_image


func _ready() -> void:
    Events.connect("request_save_position_data", _save_position_data)
    Events.connect("request_save_image", _save_image)
