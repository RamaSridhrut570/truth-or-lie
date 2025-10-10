extends Resource
class_name QuestionBatch

@export var batch_name: String = ""
@export var questions: Array[Question] = []
@export var is_unlocked: bool = true

func next_question() -> Question:
	for q in questions:
		if q.should_be_asked and not q.is_asked:
			q.is_asked = true
			return q
	return null

func reset_all() -> void:
	for q in questions:
		q.is_asked = false

func get_available_questions() -> Array[Question]:
	var available : Array[Question]  = []
	for q in questions:
		if q.should_be_asked and not q.is_asked:
			available.append(q)
	return available
