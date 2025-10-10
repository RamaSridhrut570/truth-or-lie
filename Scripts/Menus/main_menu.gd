extends Control

@onready var bg_panel: Panel = $BGPanel

## BUTTONS
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var really_start_button: Button = $Instructions_Panel/MarginContainer/ReallyStartButton

## UI PANELS & LABELS
@onready var instructions_panel: Panel = $Instructions_Panel
# NOTE: Make sure you have a Label node at this path for the instructions text.
@onready var instructions_label: Label = $Instructions_Panel/MarginContainer/GridContainer/Label

## AUDIO & ANIMATION
@onready var music: AudioStreamPlayer = $Music
@onready var sfx: AudioStreamPlayer = $SFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const GLASS_006 = preload("uid://e5lufvandqqs")
const COMPUTER_MOUSE_CLICK = preload("uid://oetn681ypdq3")
const MECH_KEYBOARD = preload("uid://c3kon1cdjkdg5")
const CONUNDRUM_TRUTH_OR_LIE_OST = preload("uid://y85gkye53hsx")

## Typewriter Effect ##
@export var typing_speed: float = 0.05 # Time in seconds between each character
var typewriter_label: Label = null
var typewriter_full_text: String = ""
var is_typing: bool = false


func _ready() -> void:
	instructions_panel.hide()
	music.stream = CONUNDRUM_TRUTH_OR_LIE_OST
	music.play()


func _input(event: InputEvent) -> void:
	# Allow player to skip typewriter effect with a mouse click
	if is_typing and event is InputEventMouseButton and event.is_pressed():
		_skip_typewriter()
		# Consume the input to prevent other actions
		get_viewport().set_input_as_handled()
		return

## Typewriter Effect Functions ##

func _start_typewriter(label_node: Label, text: String):
	if is_typing:
		_skip_typewriter()

	typewriter_label = label_node
	typewriter_full_text = text
	is_typing = true
	label_node.text = ""

	for i in range(text.length()):
		if not is_typing: # Stop if skipped
			return
		randomize()
		sfx.stream = COMPUTER_MOUSE_CLICK
		var p = randf_range(0.8, 1.4)
		sfx.pitch_scale = p
		sfx.play()
		label_node.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	typewriter_label = null
	typewriter_full_text = ""

func _skip_typewriter():
	if not is_typing:
		return

	is_typing = false
	if typewriter_label:
		typewriter_label.text = typewriter_full_text
	
	typewriter_label = null
	typewriter_full_text = ""

## Main Menu Logic ##

func instructions_screen():
	instructions_panel.show()
	start_button.hide()
	exit_button.hide()
	
	# --- ADDED CHECK ---
	# This will prevent the game from crashing if the node path is wrong.
	if not is_instance_valid(instructions_label):
		print("ERROR: The 'instructions_label' node was not found. Please check the node path in the main_menu.gd script and ensure it matches the Scene Tree.")
		return
		
	var instructions_text = "Welcome, Detective.\n\nA new case has just landed on your desk. Your mission is to interrogate the suspect and determine if their statements are truth or lie. Pay close attention to the evidence.\n\nYour accuracy will determine the outcome."
	# Use call_deferred to avoid issues with showing the panel and typing at the same time
	call_deferred("_start_typewriter", instructions_label, instructions_text)

## Signal Callbacks ##

func _on_start_button_pressed() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = COMPUTER_MOUSE_CLICK
	sfx.pitch_scale = p
	sfx.play()
	animation_player.play("start")
	await animation_player.animation_finished
	instructions_screen()


func _on_exit_button_pressed() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = COMPUTER_MOUSE_CLICK
	sfx.pitch_scale = p
	sfx.play()
	await sfx.finished
	get_tree().quit()


func _on_start_button_mouse_entered() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = GLASS_006
	sfx.pitch_scale = p
	sfx.play()


func _on_exit_button_mouse_entered() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = GLASS_006
	sfx.pitch_scale = p
	sfx.play()


func _on_really_start_button_pressed() -> void:
	# Skip the typing if it's still going
	if is_typing:
		_skip_typewriter()
		await get_tree().create_timer(0.1).timeout # Short delay
	
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = COMPUTER_MOUSE_CLICK
	sfx.pitch_scale = p
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_really_start_button_mouse_entered() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = GLASS_006
	sfx.pitch_scale = p
	sfx.play()
