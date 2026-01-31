extends Control
class_name FallMask
@onready var mask_name: Label = $MaskName

func setup(res:FaceRes):
	mask_name.text = res.face_name
