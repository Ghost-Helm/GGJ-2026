extends Control
class_name FallMask

@onready var texture_rect: TextureRect = $TextureRect
@onready var eye_frame: TextureRect = $EyeFrame

func setup(res:FaceRes):
    texture_rect.texture = res.face_img
    eye_frame.visible = res.type == FaceRes.FACE_TYPE.Eye
