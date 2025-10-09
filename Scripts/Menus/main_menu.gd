extends Control

@onready var bg_panel: Panel = $BGPanel


## BUTTONS
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton



@onready var really_start_button: Button = $Instructions_Panel/MarginContainer/ReallyStartButton


@onready var music: AudioStreamPlayer = $Music
@onready var sfx: AudioStreamPlayer = $SFX
#@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var instructions_panel: Panel = $Instructions_Panel




const GLASS_006 = preload("uid://e5lufvandqqs")
const LIFELINE_BUTTON_PRESS = preload("uid://d0o4o88ls2ypt")




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const INSTRUCTIONS_PANEL = preload("uid://sbxcg0lk81cs")
	const GAME = preload("uid://c863etmtcokno")
	#gpu_particles_2d.emitting = true
	#music.play()
	#animation_player.play("RESET")
	instructions_panel.hide()

func _process(delta: float) -> void:
	pass

func instructions_screen():
	instructions_panel.show()
	start_button.hide()
	exit_button.hide()
	

func _on_start_button_pressed() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = LIFELINE_BUTTON_PRESS
	sfx.pitch_scale = p
	sfx.play()
	animation_player.play("start")
	await animation_player.animation_finished
	instructions_screen()



func _on_exit_button_pressed() -> void:
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = LIFELINE_BUTTON_PRESS
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
	randomize()
	var p = randf_range(1, 1.4)
	sfx.stream = LIFELINE_BUTTON_PRESS
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
