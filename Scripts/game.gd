extends Control

const GLASS_006 = preload("uid://e5lufvandqqs")
const LIFELINE_BUTTON_PRESS = preload("uid://d0o4o88ls2ypt")


@onready var main_canvas_layer: CanvasLayer = $MainCanvasLayer
@onready var selection_container: MarginContainer = $MainCanvasLayer/MarginContainer/SelectionContainer
@onready var all_elements_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer
@onready var top_bar_container: HBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/TopBarContainer
@onready var q_n_a_box_container: VBoxContainer = $MainCanvasLayer/MarginContainer/AllElementsContainer/QnABoxContainer
@onready var pause_menu: Control = $MainCanvasLayer/MarginContainer/Pause_Menu
@onready var sfx: AudioStreamPlayer = $SFX

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



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ask_button.disabled = false
	selection_container.hide()
	if not ask_button.is_connected("pressed", _on_ask_button_pressed):
		ask_button.connect("pressed", _on_ask_button_pressed)
	if not cancel_button.is_connected("pressed", _on_cancel_button_pressed):
		cancel_button.connect("pressed", _on_cancel_button_pressed)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if line_edit.text.is_valid_int() and line_edit.text.length() == 1 and is_selecting == false:
		ask_button.disabled = false
	else:
		ask_button.disabled = true

func _input(event: InputEvent) -> void:
	if not is_selecting:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if click is inside Draggable_Answer panel
				var panel_rect = draggable_answer.get_global_rect()
				if panel_rect.has_point(event.position):
					_start_drag(event.position)
			else:
				# Released mouse
				if is_dragging_answer:
					_end_drag(event.position)
	# Update drag label position
	if event is InputEventMouseMotion and is_dragging_answer and drag_label:
		drag_label.global_position = event.position - drag_offset
		
		# Check if hovering over truth or lie panels
		var truth_rect = truth_side.get_global_rect()
		var lie_rect = lie_side.get_global_rect()
		
		if truth_rect.has_point(event.position):
			truth_side.modulate = Color(0.0, 1.0, 0.0, 1.0)  # Green tint
			lie_side.modulate = Color(1.0, 1.0, 1.0)    # Reset lie side
		elif lie_rect.has_point(event.position):
			lie_side.modulate = Color(1.0, 0.0, 0.0, 1.0)    # Red tint
			truth_side.modulate = Color(1.0, 1.0, 1.0)  # Reset truth side
		else:
			# Not hovering over either - reset both
			truth_side.modulate = Color(1.0, 1.0, 1.0)
			lie_side.modulate = Color(1.0, 1.0, 1.0)

func _start_drag(mouse_pos: Vector2) -> void:
	is_dragging_answer = true
	original_answer_text = answers_label.text
	answers_label.text = ""  # Hide original text
	
	# Create temporary label
	drag_label = Label.new()
	drag_label.text = original_answer_text
	drag_label.add_theme_font_size_override("font_size", answers_label.get_theme_font_size("font_size"))
	# Copy other styling from answers_label if needed
	
	main_canvas_layer.add_child(drag_label)
	drag_label.global_position = mouse_pos
	
	drag_label.z_index = 40

func _end_drag(drop_position: Vector2) -> void:
	var truth_rect = truth_side.get_global_rect()
	var lie_rect = lie_side.get_global_rect()
	
	if truth_rect.has_point(drop_position):
		print("Dropped on TRUTH!")
		# Handle judgment
	elif lie_rect.has_point(drop_position):
		print("Dropped on LIE!")
		# Handle judgment
	else:
		print("Dropped outside - cancelled")
	
	# Reset modulate
	truth_side.modulate = Color(1.0, 1.0, 1.0)
	lie_side.modulate = Color(1.0, 1.0, 1.0)
	
	# Clean up
	answers_label.text = original_answer_text  # Restore text
	if drag_label:
		drag_label.queue_free()
		drag_label = null
	is_dragging_answer = false

func _on_ask_button_pressed() -> void:
	selection_container.show()
	ask_button.disabled = true
	is_selecting = true
	# ensure the button does not retain focus after being pressed
	ask_button.release_focus()
	

func _on_cancel_button_pressed() -> void:
	selection_container.hide()
	ask_button.disabled = false
	is_selecting = false
	# ensure the cancel (and other) buttons do not keep focus
	cancel_button.release_focus()


func _on_pause_button_pressed() -> void:
	pause_menu._pause()
	randomize()
	sfx.stream = LIFELINE_BUTTON_PRESS
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()


func _on_pause_button_mouse_entered() -> void:
	randomize()
	sfx.stream = GLASS_006
	var p = randf_range(1, 1.4)
	sfx.pitch_scale = p
	sfx.play()
