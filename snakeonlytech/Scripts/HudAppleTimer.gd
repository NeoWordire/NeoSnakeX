extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#for x in 5:
		#get_node("apple" + String(x)).visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var apple = get_parent().get_parent().get_node("Food")
	
	var numapples = ceil(apple.respawntimer.time_left/apple.respawntime*5)
	for x in range(1,6):
		if (x > numapples):
			get_node("apple" + String(x)).visible = true
		else:
			get_node("apple" + String(x)).visible = false
#	for x in range(numapples,5):
#		get_node("apple" + String(x)).visible = false
	pass
