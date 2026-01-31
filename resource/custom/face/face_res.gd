extends Resource
class_name FaceRes

enum FACE_TYPE{HairCut,Eyebrow, Mouse, Other}
enum MASK_ACT_TYPE{Fall,Change}
enum MASK_CHANGE_TYPE{None,Hair,SkinTone,FaceShape}

@export var face_name: StringName
@export var face_img: Texture2D
@export var type: FACE_TYPE
@export var dialog: String
@export var mask_type:MASK_ACT_TYPE
@export var change_type:MASK_CHANGE_TYPE
