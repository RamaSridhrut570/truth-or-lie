extends Control

const GLASS_006 = preload("uid://e5lufvandqqs")
const COMPUTER_MOUSE_CLICK = preload("uid://oetn681ypdq3")
const ANSWER_TRUTHORLIE = preload("uid://hmur04yo6rm5")
const MECH_KEYBOARD = preload("uid://c3kon1cdjkdg5")
const LOW_ENDING = preload("uid://cylhfxbaawwci")


## Question Batches ##
@export var Question_Batches_Array: Array[QuestionBatch]

## Typewriter Effect ##
@export var typing_speed: float = 0.05 # Time in seconds between each character

@onready var main_canvas_layer: CanvasLayer = $MainCanvasLayer
@onready var selection_container: MarginContainer = $MainCanvasLayer/MarginContainer/SelectionContainer
@onready var all_elements_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer
@onready var top_bar_container: HBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer
@onready var q_n_a_box_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer
@onready var pause_menu: Control = $MainCanvasLayer/MarginContainer/Pause_Menu
@onready var sfx: AudioStreamPlayer = $SFX
@onready var truth_sound: AudioStreamPlayer2D = $Truth_Sound
@onready var lie_sound: AudioStreamPlayer2D = $Lie_Sound
@onready var evidence_screen: Control = $MainCanvasLayer/MarginContainer/Evidence_Screen
@onready var music: AudioStreamPlayer = $Music

## Top Bar UI Nodes ##
@onready var pause_button: Button = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer/Pause_Button
@onready var instruction_label: Label = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer/Instruction_Label
@onready var evidence_button: Button = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer/Evidence_Button
@onready var case_file_button: Button = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer/CaseFile_Button

## Questions UI Nodes
@onready var ques_box_title_label: Label = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer/QuestionsBox/MarginContainer/QuesBoxContainer/QuesBoxTitleLabel
@onready var questions_label: Label = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer/QuestionsBox/MarginContainer/QuesBoxContainer/QuestionsLabel
@onready var line_edit: LineEdit = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer/QuestionsBox/MarginContainer/QuesBoxContainer/HBoxContainer/LineEdit
@onready var ask_button: Button = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer/QuestionsBox/MarginContainer/QuesBoxContainer/HBoxContainer/AskButton

## Selection UI Nodes ##
@onready var ans_box_title_label: Label = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/AnsBoxTitleLabel
@onready var truth_side: Panel = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/AnsBoxContainer/TruthSide
@onready var draggable_answer: Panel = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/AnsBoxContainer/Draggable_Answer
@onready var answers_label: Label = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/AnsBoxContainer/Draggable_Answer/AnswersLabel
@onready var lie_side: Panel = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/AnsBoxContainer/LieSide
@onready var cancel_button: Button = $MainCanvasLayer/MarginContainer/SelectionContainer/SelectionBox/MarginContainer/CancelButton

## Selecting Answers ##
var is_selecting: bool = false
var is_dragging_answer := false
var drag_offset := Vector2.ZERO
var original_answer_text := ""
var drag_label: Label = null

## Game State Variables ##
var current_batch: QuestionBatch
var current_question: Question
var available_questions: Array[Question] = []
var correct_answers: int = 0
var total_questions_answered: int = 0

## Typewriter State ##
var typewriter_label: Label = null
var typewriter_full_text: String = ""
var is_typing: bool = false

var original_pitch: float = 1.2

func _ready() -> void:
	_reset_all_batches_to_default()
	selection_container.hide()
	if not ask_button.is_connected("pressed", _on_ask_button_pressed):
		ask_button.connect("pressed", _on_ask_button_pressed)
	if not cancel_button.is_connected("pressed", _on_cancel_button_pressed):
		cancel_button.connect("pressed", _on_cancel_button_pressed)
	
	_load_current_batch()
	_display_available_questions()


func _process(delta: float) -> void:
	if is_selecting or is_typing:
		ask_button.disabled = true
		return
		
	if line_edit.text.is_valid_int():
		var selected_num = line_edit.text.to_int()
		if selected_num > 0 and selected_num <= available_questions.size():
			ask_button.disabled = false
		else:
			ask_button.disabled = true
	else:
		ask_button.disabled = true

func _input(event: InputEvent) -> void:
	# Allow player to skip typewriter effect with a mouse click
	if is_typing and event is InputEventMouseButton and event.is_pressed():
		_skip_typewriter()
		# Consume the input to prevent other actions
		get_viewport().set_input_as_handled()
		return

	if not is_selecting:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var panel_rect = draggable_answer.get_global_rect()
				if panel_rect.has_point(event.position):
					_start_drag(event.position)
			else:
				if is_dragging_answer:
					_end_drag(event.position)
	if event is InputEventMouseMotion and is_dragging_answer and drag_label:
		drag_label.global_position = event.position - drag_offset
		
		var truth_rect = truth_side.get_global_rect()
		var lie_rect = lie_side.get_global_rect()
		
		if truth_rect.has_point(event.position):
			truth_side.modulate = Color(0.0, 1.0, 0.0, 1.0)
			lie_side.modulate = Color(1.0, 1.0, 1.0)
		elif lie_rect.has_point(event.position):
			lie_side.modulate = Color(1.0, 0.0, 0.0, 1.0)
			truth_side.modulate = Color(1.0, 1.0, 1.0)
		else:
			truth_side.modulate = Color(1.0, 1.0, 1.0)
			lie_side.modulate = Color(1.0, 1.0, 1.0)

func _start_drag(mouse_pos: Vector2) -> void:
	is_dragging_answer = true
	original_answer_text = answers_label.text
	answers_label.text = ""
	
	drag_label = Label.new()
	drag_label.text = original_answer_text
	drag_label.add_theme_font_size_override("font_size", answers_label.get_theme_font_size("font_size"))
	
	main_canvas_layer.add_child(drag_label)
	drag_label.global_position = mouse_pos
	drag_label.z_index = 40

func _end_drag(drop_position: Vector2) -> void:
	var truth_rect = truth_side.get_global_rect()
	var lie_rect = lie_side.get_global_rect()
	var truth_selected: bool
	var choice_made = false
	
	if truth_rect.has_point(drop_position):
		truth_selected = true
		choice_made = true
	elif lie_rect.has_point(drop_position):
		truth_selected = false
		choice_made = true
	
	answers_label.text = original_answer_text
	if drag_label:
		drag_label.queue_free()
		drag_label = null
	is_dragging_answer = false
	
	truth_side.modulate = Color(1.0, 1.0, 1.0)
	lie_side.modulate = Color(1.0, 1.0, 1.0)
	
	if choice_made:
		_handle_player_judgment(truth_selected)

## Typewriter Effect Functions ##

func _start_typewriter(label_node: Label, text: String):
	if is_typing:
		_skip_typewriter()

	typewriter_label = label_node
	typewriter_full_text = text
	is_typing = true
	label_node.text = ""

	for i in range(text.length()):
		if not is_typing:
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

## Custom Game Logic Functions ##

func _reset_all_batches_to_default():
	for i in range(Question_Batches_Array.size()):
		var batch = Question_Batches_Array[i]
		batch.reset_all()
		batch.is_unlocked = (i == 0)

func _load_current_batch() -> void:
	for batch in Question_Batches_Array:
		if batch.is_unlocked:
			current_batch = batch
			return
	print("ERROR: No unlocked question batches found!")

func _display_available_questions() -> void:
	if not current_batch:
		questions_label.text = "No question batch loaded."
		return
		
	available_questions = current_batch.get_available_questions()
	var displayed_text = ""
	for i in range(available_questions.size()):
		var q = available_questions[i]
		displayed_text += str(i + 1) + ". " + q.text + "\n"
	
	call_deferred("_start_typewriter", questions_label, displayed_text)


func _handle_player_judgment(player_choice_is_truth: bool) -> void:
	total_questions_answered += 1
	
	if player_choice_is_truth == current_question.answer_is_truth:
		correct_answers += 1
	
	selection_container.hide()
	is_selecting = false
	line_edit.text = ""
	
	_display_available_questions()
	_check_batch_completion()


func _check_batch_completion() -> void:
	if available_questions.is_empty():
		var current_batch_index = Question_Batches_Array.find(current_batch)

		if current_batch_index != -1 and current_batch_index + 1 < Question_Batches_Array.size():
			current_batch.is_unlocked = false
			var next_batch = Question_Batches_Array[current_batch_index + 1]
			next_batch.is_unlocked = true
			music.pitch_scale -= 0.1 
			_load_current_batch()
			_display_available_questions()
		else:
			music.pitch_scale -= 0.6
			if total_questions_answered > 0:
				var accuracy_percentage = (float(correct_answers) / total_questions_answered) * 100.0
				if total_questions_answered > 9:
					_start_typewriter(instruction_label, "- You cannot do this")
				if accuracy_percentage >= 70.0:
					_trigger_high_accuracy_ending()
				else:
					_trigger_low_accuracy_ending()

## Ending Cutscene Triggers (Templates) ##
func _trigger_high_accuracy_ending():
	print("--- TRIGGERING HIGH ACCURACY ENDING ---")
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://Scenes/Endings/low_ending.tscn")

func _trigger_low_accuracy_ending():
	print("--- TRIGGERING LOW ACCURACY ENDING ---")
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://Scenes/Endings/low_ending.tscn")
	

## Signal Callbacks ##

func _on_ask_button_pressed() -> void:
	var selected_index = line_edit.text.to_int() - 1
	
	if selected_index < 0 or selected_index >= available_questions.size():
		return
	
	
	randomize()
	sfx.stream = COMPUTER_MOUSE_CLICK
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
	
	current_question = available_questions[selected_index]
	
	# Mark question as asked and update the list in the background
	current_question.is_asked = true
	_display_available_questions()
	
	# Start typing out the answer
	call_deferred("_start_typewriter", answers_label, current_question.Answer)
	
	selection_container.show()
	is_selecting = true

func _on_cancel_button_pressed() -> void:
	_skip_typewriter()

	if current_question:
		current_question.is_asked = false

	selection_container.hide()
	is_selecting = false
	
	_display_available_questions()

func _on_pause_button_pressed() -> void:
	pause_menu._pause()
	randomize()
	sfx.stream = COMPUTER_MOUSE_CLICK
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()

func _on_pause_button_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()


func _on_evidence_button_pressed() -> void:
	evidence_screen._pause()
	randomize()
	sfx.stream = COMPUTER_MOUSE_CLICK
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()


func _on_evidence_button_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
