extends Control

@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/Panel/GridContainer/VScrollBar/Label

## Buttons
@onready var resume: Button = $MarginContainer/Panel/GridContainer/RESUME
@onready var sfx: AudioStreamPlayer = $SFX

## Preload Scenes
const MAIN_MENU = preload("res://Scenes/Menus/main_menu.tscn")
const GLASS_006 = preload("uid://e5lufvandqqs")
const COMPUTER_MOUSE_CLICK = preload("uid://oetn681ypdq3")


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
	if event.is_action_pressed("evidence") and not is_paused:
		_pause()
	elif event.is_action_pressed("evidence") and is_paused:
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
	sfx.stream = COMPUTER_MOUSE_CLICK
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
	_resumed()



func _on_resume_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
