extends Control

@export var audio_list: Array[AudioStream]
@export var sound_answer_res_group: ResourceGroup

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var h_box_container: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var h_box_container_2: HBoxContainer = $VBoxContainer/HBoxContainer2


var button_list: Array[Button]

var current_question: String
var current_answer: PackedInt32Array

var player_answer: PackedInt32Array


func _play_sound() -> void:
    Events.emit_signal("request_stop_music")

    for button in button_list:
        button.disabled = true

    var index: int = 0
    for audio in audio_list:
        var button: Button = button_list[index]
        button.text = "true"

        audio_stream_player.stream = audio
        audio_stream_player.play()
        await audio_stream_player.finished

        button.text = "false"

        index += 1

    for button in button_list:
        button.disabled = false

    Events.emit_signal("request_replay_music")


func _pressed(button: Button) -> void:
    var VB: VBoxContainer = VBoxContainer.new()
    h_box_container_2.add_child(VB)
    VB.name = "VB"
    VB.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var label: Label = Label.new()
    label.text = current_question[VB.get_index()]
    VB.add_child(label)
    label.name = "L"
    label.size_flags_vertical = Control.SIZE_EXPAND_FILL

    var b: Button = button.duplicate()
    VB.add_child(b)
    b.name = "B"
    b.text = str(button.get_index())
    b.size_flags_vertical = Control.SIZE_EXPAND_FILL

    player_answer.append(button.get_index())

    if VB.get_index() == current_question.length() - 1:
        _finish()


func _finish() -> void:
    print(player_answer == current_answer)


func _ready() -> void:
    for button: Button in h_box_container.get_children():
        button_list.append(button)
        button.connect("pressed", _pressed.bind(button))

    var question_list: Array[StringName]
    var answer_list: Array[PackedInt32Array]

    for sound_answer_res: SoundAnswerRes in sound_answer_res_group.load_all():
        question_list.append(sound_answer_res.question)
        answer_list.append(sound_answer_res.answer)

    var index: int = randi_range(0, question_list.size() - 1)

    current_question = question_list[index]
    current_answer = answer_list[index]
