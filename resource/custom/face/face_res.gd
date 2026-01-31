extends Resource
class_name FaceRes

enum FACE_TYPE{Eye, Eyebrow, Nose, Mouse, Other}

@export var face_name: StringName
@export var face_img: Texture2D
@export var type: FACE_TYPE
@export var dialog: String
