extends Control

@onready var margin_container: MarginContainer = $MarginContainer

## Buttons
@onready var resume: Button = $MarginContainer/Panel/GridContainer/VBoxContainer/RESUME
@onready var exit_to_menu: Button = $MarginContainer/Panel/GridContainer/VBoxContainer/EXIT_TO_MENU
@onready var sfx: AudioStreamPlayer = $SFX

## Preload Scenes
const MAIN_MENU = preload("res://Scenes/Menus/main_menu.tscn")
const GLASS_006 = preload("uid://e5lufvandqqs")
const LIFELINE_BUTTON_PRESS = preload("uid://d0o4o88ls2ypt")


var is_paused : bool = false


func _tween_appear():
	var tween = create_tween()
	self.show()
	tween.tween_property(margin_container, "modulate", Color(1, 1, 1, 1), 0.2)
	self.show()

func _tween_disappear():
	var tween = create_tween()
	tween.tween_property(margin_container, "modulate", Color(1, 1, 1, 0), 0.4)
	await get_tree().create_timer(0.4).timeout
	self.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	is_paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_paused:
		_pause()
	elif event.is_action_pressed("ui_cancel") and is_paused:
		_resumed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pause():
	if not is_paused:
		get_tree().paused = true
		is_paused = true
		_tween_appear()

func _resumed():
	if is_paused:
		_tween_disappear()
		get_tree().paused = false
		is_paused = false
	

func _on_resume_pressed() -> void:
	randomize()
	sfx.stream = LIFELINE_BUTTON_PRESS
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
	_resumed()
	# release focus so Resume doesn't stay highlighted
	resume.release_focus()



func _on_exit_to_menu_pressed() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = LIFELINE_BUTTON_PRESS
	sfx.pitch_scale = p
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	_tween_disappear()
	get_tree().paused = false
	is_paused = false
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	# release focus so the Exit-to-Menu button doesn't retain focus
	exit_to_menu.release_focus()



func _on_resume_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()


func _on_exit_to_menu_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
