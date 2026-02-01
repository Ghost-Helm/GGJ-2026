extends Node

var position_data: PackedVector3Array
var image: Image


func save_position_data(data: PackedVector3Array) -> void:
    position_data = data


func save_image(target_image: Image) -> void:
    image = target_image
    image.save_png("user://uncut.png")
    var cut_image: Image = image.get_region(Rect2i(297, 70, 672, 922))
    cut_image.save_png("user://cut.png")
    image = cut_image
    
    
func get_position_data() -> PackedVector3Array:
    return position_data

func get_image() -> Image:
    return image
