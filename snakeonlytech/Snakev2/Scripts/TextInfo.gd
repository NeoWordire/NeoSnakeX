extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.visible = false
	pass # Replace with function body.

func changeState(battlestate):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	pass
