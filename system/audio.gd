extends Node


func _stop_music() -> void:
    music_player.stop()


func _replay_music() -> void:
    music_player.play()


func _play_music(music_name) -> void:
    music_player.stream = _music_res_map[music_name]
    music_player.play()


func _play_sound(sound_name: StringName) -> void:
    sound_player.stream = _sound_res_map[sound_name]
    sound_player.play()


func _ready() -> void:
    Events.connect("request_play_music", _play_music)
    Events.connect("request_play_sound", _play_sound)
    Events.connect("request_stop_music", _stop_music)
    Events.connect("request_replay_music", _replay_music)

    for music_res in music_res_group.load_all():
        _music_res_map[music_res.music_name] = music_res.stream

    for sound_res in sound_res_group.load_all():
        _sound_res_map[sound_res.sound_name] = sound_res.stream


@export var music_res_group: ResourceGroup
@export var sound_res_group: ResourceGroup
@export var music_player: AudioStreamPlayer
@export var sound_player: AudioStreamPlayer

var _music_res_map: Dictionary
var _sound_res_map: Dictionary
