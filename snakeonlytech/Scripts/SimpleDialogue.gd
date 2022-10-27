extends PanelContainer

export (NodePath) var Characters

var cory = load("res://Dialogue/Characters/Cory.tscn")
var apple = load("res://Dialogue/Characters/Apple.tscn")
signal finish_line_early

# Called when the node enters the scene tree for the first time.

func _ready():
 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("ui_accept")):
		emit_signal("finish_line_early")
		get_parent().finish_line()


func _on_YarnRunner_command_emitted(command, arguments):
	print(command, " ", arguments)
	if (command == "fade"):
		if (arguments[0] == "in"):
			pass
		if (arguments[0] == "out"):
			pass
	if (command == "spawn_sprite"):
		var spawn
		if (arguments[0] == "cory"):
			spawn = cory.instance()
			pass
		if (arguments[0] == "apple"):
			spawn = apple.instance()
			pass
		var location

		if (arguments[1] == "left"):
			location = get_node(Characters).get_node("left")
			pass
		if (arguments[1] == "right"):
			location = get_node(Characters).get_node("right")
			pass
		for child in location.get_children():
			location.remove_child(child)
		location.add_child(spawn)
	if (command == "move_sprite"):
		var spawn
		if (arguments[0] == "cory"):
			spawn = cory.instance()
			pass
		if (arguments[0] == "apple"):
			spawn = apple.instance()
			pass
		var sourcelocation
		var destlocation
		if (arguments[1] == "left"):
			sourcelocation = get_node(Characters).get_node("right")
			destlocation = get_node(Characters).get_node("left")
			pass
		if (arguments[1] == "right"):
			sourcelocation = get_node(Characters).get_node("left")
			destlocation = get_node(Characters).get_node("right")
			pass
		for child in sourcelocation.get_children():
			sourcelocation.remove_child(child)
		destlocation.add_child(spawn)
	if (command == "remove_sprite"):
		var location
		if (arguments[0] == "left"):
			location = get_node(Characters).get_node("left")
			pass
		if (arguments[0] == "right"):
			location = get_node(Characters).get_node("right")
			pass
		for child in location.get_children():
			location.remove_child(child)
	pass # Replace with function body.

func _on_YarnDisplay_line_started(name, line):
	for pos in get_node(Characters).get_children():
		for child in pos.get_children():
			child.line_emitted(name, line)
	pass # Replace with function body.


func _on_YarnDisplay_line_finished():
	for pos in get_node(Characters).get_children():
		for child in pos.get_children():
			child.line_finished()
	pass # Replace with function body.
