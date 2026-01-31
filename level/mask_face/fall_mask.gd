extends Control
class_name FallMask

@onready var texture_rect: TextureRect = $TextureRect

func setup(res:FaceRes):
	texture_rect.texture = res.face_img
	
