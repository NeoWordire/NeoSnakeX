extends LineEdit

export (String) var nextScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready name")
	grab_focus()
	pass # Replace with function body.

func getyourname():
	print("chipy")
	self.raise()
#Dialogic.set_variable("yourname", yourname)
	pass

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		if(self.text != ""):
			GlobalSnakeVar.g_yourname = self.text
			get_tree().change_scene(nextScene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
