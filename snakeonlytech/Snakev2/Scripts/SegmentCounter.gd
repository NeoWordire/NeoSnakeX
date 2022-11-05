extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (NodePath) var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Score").text = "X" + String(get_node(player).get_node("Body").get_child_count())
	#uiCooldown += _del
	pass
