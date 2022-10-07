extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_YarnRunner_command_emitted(command, arguments):
	print("command = ", command)
	if (command == "battletime"):
	  #get_tree().change_scene("res://Battle.tscn")
	  get_child(0).visible = true
	  get_child(1).visible = false
	if (command == "goodending"):
		get_tree().change_scene("res://goodending.tscn")
	#.visible = true

	pass # Replace with function body.


func _on_YarnRunner_line_emitted(line):
	if (line.get_slice(":", 0) == "Cutie1"):
		get_parent().get_child(1).visible = true
	else:
		get_parent().get_child(1).visible = false
	pass # Replace with function body.


func _on_YarnRunner_dialogue_started():
	pass # Replace with function body.


func _on_MenuDisplay_text_changed():
	pass # Replace with function body.


func _on_MenuDisplay_line_started():
	pass # Replace with function body.
