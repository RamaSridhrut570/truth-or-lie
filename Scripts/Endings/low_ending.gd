extends Control

@onready var label: Label = $MarginContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialogues: AudioStreamPlayer = $Dialogues

const LOW_ENDING = preload("uid://csq86tsqwwhy7")
const MAIN_MENU = preload("uid://btyyar3txrbaq")


func _ready() -> void:
	dialogues.stream = LOW_ENDING
	dialogues.play()


func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
