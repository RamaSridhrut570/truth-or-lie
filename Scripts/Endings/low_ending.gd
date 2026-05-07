extends Control

@onready var label: Label = $MarginContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialogues: AudioStreamPlayer = $Dialogues
@onready var music: AudioStreamPlayer = $Music

const LOW_ENDING = preload("uid://csq86tsqwwhy7")
const MAIN_MENU = preload("uid://btyyar3txrbaq")
const STUDIO_NAME := (
'''Λ M Λ R Λ M 
Studio'''
)
var ending_complete := false
var credits_started := false


func _ready() -> void:
	var payload: Dictionary = {}
	if get_tree().has_meta("ending_payload"):
		payload = get_tree().get_meta("ending_payload") as Dictionary
		get_tree().remove_meta("ending_payload")

	var ending_key := String(payload.get("ending_key", "collapse"))

	if ending_key == "collapse":
		dialogues.stream = LOW_ENDING
		dialogues.play()
		music.pitch_scale = 0.6
		animation_player.play("Ending")
		return

	animation_player.stop(true)
	label.text = ""
	if ending_key == "vindication":
		music.pitch_scale = 1.0
		_play_custom_ending([
			"The lies cracked under pressure.",
			"You rebuilt the timeline before panic could bury it.",
			"An innocent walks free... and the real culprit waits in cuffs.",
			"CASE CLOSED."
		], 1.8)
	else:
		music.pitch_scale = 0.8
		_play_custom_ending([
			"The truth surfaced, but only in fragments.",
			"Too many contradictions still breathe in the file.",
			"Tonight, justice is delayed... not denied.",
			"TO BE CONTINUED."
		], 2.0)


func _play_custom_ending(lines: Array[String], line_hold_time: float) -> void:
	for line in lines:
		label.text = line
		await get_tree().create_timer(line_hold_time).timeout

	await _show_credit_card_then_exit()


func _show_credit_card_then_exit() -> void:
	if credits_started:
		return

	credits_started = true
	ending_complete = true
	label.add_theme_font_size_override("font_size", 48)
	label.text = "\n" + STUDIO_NAME
	await get_tree().create_timer(64).timeout
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _process(_delta: float) -> void:
	pass


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if ending_complete:
		return
	await _show_credit_card_then_exit()
