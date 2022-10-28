extends LineEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var yourname = ""

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

var done = false
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		if(!done && self.text != ""):
			var new_dialog = Dialogic.start('First Scene')
			Dialogic.set_variable("yourname", self.text)
			add_child(new_dialog)
			done = true
			print("start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
