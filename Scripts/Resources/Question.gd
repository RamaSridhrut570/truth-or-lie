# res://scripts/Question.gd
extends Resource
class_name Question

# Exported properties show up in the Inspector
@export_multiline var text : String = ""
@export var is_asked : bool = false
@export var should_be_asked : bool = true
