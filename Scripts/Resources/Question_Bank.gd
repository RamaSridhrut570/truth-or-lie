# res://scripts/QuestionBank.gd
extends Resource
class_name QuestionBank

# An array of Question resources
@export var questions: Array[Question] = []

# Returns the next unasked question, marking it as asked
func next_question() -> Question:
	for q in questions:
		if q.should_be_asked and not q.is_asked:
			q.is_asked = true
			return q
	return null  # no more questions available

# Reset all questions to unasked
func reset_all():
	for q in questions:
		q.is_asked = false
