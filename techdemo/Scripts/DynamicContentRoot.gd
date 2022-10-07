extends Control

#export(Resource) var sprite[] = []
#export(Array, Texture) var sprites
#export(Array, String) var chars
export(Dictionary) var CharacterSprites = {
}
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
	  get_node("BattleScene1").visible = true
	  get_node("DialogueMenuDisplay").visible = false
	  get_node("BattleScene1/PlayerSnake").reset()
	  get_node("BattleScene1/PlayerSnake").battleactive = true
	if (command == "goodending"):
		get_tree().change_scene("res://goodending.tscn")
	#.visible = true

	pass # Replace with function body.


func _on_YarnRunner_line_emitted(line):
	var character = line.get_slice(":", 0)
	print(character)
	if (character == line):
		get_parent().get_node("NPC").visible = false
		return
	print(character)
	if (CharacterSprites.has(character)):
		get_parent().get_node("NPC").texture = CharacterSprites[character]
		get_parent().get_node("NPC").visible = true
	else:
		print("DEBUG CHARACTER FROM YARN NOT FOUND")
	pass # Replace with function body.


func _on_YarnRunner_dialogue_started():
	pass # Replace with function body.


func _on_MenuDisplay_text_changed():
	pass # Replace with function body.


func _on_MenuDisplay_line_started():
	pass # Replace with function body.
