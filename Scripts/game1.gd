extends Control

const GLASS_006 = preload("uid://e5lufvandqqs")
const COMPUTER_MOUSE_CLICK = preload("uid://oetn681ypdq3")
const ANSWER_TRUTHORLIE = preload("uid://hmur04yo6rm5")
const BUTTON_PRESS_2 = preload("uid://dh8h3xshv17dm")

## Question Batches ##
@export var Question_Batches_Array: Array[QuestionBatch]

@onready var main_canvas_layer: CanvasLayer = $MainCanvasLayer
@onready var selection_container: MarginContainer = $MainCanvasLayer/MarginContainer/SelectionContainer
@onready var all_elements_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer
@onready var top_bar_container: HBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer
@onready var q_n_a_box_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer
@onready var pause_menu: Control = $MainCanvasLayer/MarginContainer/Pause_Menu
@onready var sfx: AudioStreamPlayer = $SFX
@onready var truth_sound: AudioStreamPlayer2D = $Truth_Sound
@onready var lie_sound: AudioStreamPlayer2D = $Lie_Sound

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Reset all questions and unlock status to default before starting
	_reset_all_batches_to_default()
	selection_container.hide()
	if not ask_button.is_connected("pressed", _on_ask_button_pressed):
		ask_button.connect("pressed", _on_ask_button_pressed)
	if not cancel_button.is_connected("pressed", _on_cancel_button_pressed):
		cancel_button.connect("pressed", _on_cancel_button_pressed)
	
	_load_current_batch()
	_display_available_questions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_selecting:
		ask_button.disabled = true
		return
		
	if line_edit.text.is_valid_int():
		var selected_num = line_edit.text.to_int()
		# Check if the number is within the valid range of available questions
		if selected_num > 0 and selected_num <= available_questions.size():
			ask_button.disabled = false
		else:
			ask_button.disabled = true
	else:
		ask_button.disabled = true

func _input(event: InputEvent) -> void:
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
			truth_side.modulate = Color(0.0, 1.0, 0.0, 1.0)  # Green tint
			lie_side.modulate = Color(1.0, 1.0, 1.0)    # Reset lie side
		elif lie_rect.has_point(event.position):
			lie_side.modulate = Color(1.0, 0.0, 0.0, 1.0)    # Red tint
			truth_side.modulate = Color(1.0, 1.0, 1.0)  # Reset truth side
		else:
			truth_side.modulate = Color(1.0, 1.0, 1.0)
			lie_side.modulate = Color(1.0, 1.0, 1.0)


func _reset_all_batches_to_default() -> void:
	print("Resetting all question batches to default state.")
	# Loop through all batches in the array
	for i in range(Question_Batches_Array.size()):
		var batch = Question_Batches_Array[i]
		
		# Call the reset function within each batch resource
		# This sets is_asked to false for all its questions
		batch.reset_all() 
		
		# Ensure only the first batch (at index 0) is unlocked
		if i == 0:
			batch.is_unlocked = true
		else:
			batch.is_unlocked = false


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
		print("Dropped on TRUTH!")
		randomize()
		truth_sound.stream = ANSWER_TRUTHORLIE
		var p = randf_range(0.4, 0.8)
		truth_sound.pitch_scale = p
		truth_sound.play()
		
		truth_selected = true
		choice_made = true
	elif lie_rect.has_point(drop_position):
		print("Dropped on LIE!")
		randomize()
		lie_sound.stream = ANSWER_TRUTHORLIE
		var p = randf_range(0.4, 0.8)
		lie_sound.pitch_scale = p
		lie_sound.play()
		
		truth_selected = false
		choice_made = true
	else:
		print("Dropped outside - cancelled")
	
	# Clean up drag UI elements
	answers_label.text = original_answer_text
	if drag_label:
		drag_label.queue_free()
		drag_label = null
	is_dragging_answer = false
	
	# Reset panel colors
	truth_side.modulate = Color(1.0, 1.0, 1.0)
	lie_side.modulate = Color(1.0, 1.0, 1.0)
	
	# If a valid choice was made, process the player's judgment
	if choice_made:
		_handle_player_judgment(truth_selected)

## Custom Game Logic Functions ##

func _load_current_batch() -> void:
	for batch in Question_Batches_Array:
		if batch.is_unlocked:
			current_batch = batch
			print("Loaded question batch: " + batch.batch_name)
			return # Exit after finding the first unlocked batch
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
	
	questions_label.text = displayed_text

func _handle_player_judgment(player_choice_is_truth: bool) -> void:
	# Mark the question as asked so it doesn't reappear
	current_question.is_asked = true
	total_questions_answered += 1
	
	# Check if the player's judgment matches the answer's truth value
	if player_choice_is_truth == current_question.answer_is_truth:
		correct_answers += 1
		print("Judgment was CORRECT.")

	else:
		print("Judgment was INCORRECT.")
		
	print("Current accuracy: %d / %d" % [correct_answers, total_questions_answered])
	
	# Reset UI for the next question
	selection_container.hide()
	is_selecting = false
	line_edit.text = ""
	
	# Refresh the list of questions
	_display_available_questions()
	
	# Check if the game should end
	_check_for_game_end()

func _check_for_game_end() -> void:
	# If there are no more questions to ask in the current batch
	if available_questions.is_empty():
		print("All questions answered!")
		if total_questions_answered > 0:
			var accuracy_percentage = (float(correct_answers) / total_questions_answered) * 100.0
			print("Final Accuracy: %.2f%%" % accuracy_percentage)
			if accuracy_percentage >= 70.0:
				_trigger_high_accuracy_ending()
			else:
				_trigger_low_accuracy_ending()
		else:
			print("No questions were answered.")
			
## Ending Cutscene Triggers (Templates) ##
func _trigger_high_accuracy_ending() -> void:
	# This function will be used to show the high-accuracy ending cutscene.
	print("--- TRIGGERING HIGH ACCURACY ENDING ---")
	# Example: get_tree().change_scene_to_file("res://good_ending.tscn")

func _trigger_low_accuracy_ending() -> void:
	# This function will be used to show the low-accuracy ending cutscene.
	print("--- TRIGGERING LOW ACCURACY ENDING ---")
	# Example: get_tree().change_scene_to_file("res://bad_ending.tscn")

## Signal Callbacks ##

func _on_ask_button_pressed() -> void:
	var selected_index = line_edit.text.to_int() - 1
	
	if selected_index < 0 or selected_index >= available_questions.size():
		print("Invalid question number selected.")
		return
	
	randomize()
	sfx.stream = COMPUTER_MOUSE_CLICK
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
	
	current_question = available_questions[selected_index]
	answers_label.text = current_question.Answer
	
	# Show selection screen and update state
	selection_container.show()
	is_selecting = true
	ask_button.release_focus()

func _on_cancel_button_pressed() -> void:
	selection_container.hide()
	is_selecting = false
	cancel_button.release_focus()

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
