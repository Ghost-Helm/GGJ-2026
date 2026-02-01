extends Resource
class_name FaceRes

enum FACE_TYPE{Eye, Eyebrow, Nose, Mouse}
enum EMOTION_TYPE{Happy, Sad, Nothing}

@export var face_name: StringName
@export var face_img: Texture2D
@export var type: FACE_TYPE
@export var dialog: String
@export var emotion:EMOTION_TYPE
