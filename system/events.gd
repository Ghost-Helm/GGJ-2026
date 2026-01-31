extends Node

signal request_change_level(level_name: StringName)

signal request_play_music(music_name: StringName)
signal request_play_sound(sound_name: StringName)


signal request_save_position_data(data: PackedVector2Array)
signal request_save_image(image: Image)
