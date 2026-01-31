extends Resource
class_name FaceRes

enum FACE_TYPE{HairCut,Eyebrow, Mouse, Other}

@export var face_name: StringName
@export var face_img: Texture2D
@export var type: FACE_TYPE
