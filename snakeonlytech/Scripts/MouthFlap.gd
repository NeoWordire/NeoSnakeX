extends Sprite


# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	stopFlapping()	
	pass # Replace with function body.

func line_emitted(name, line):
	print("starty XXX =", name)
	if(name == self.name):
		startFlapping()
	pass
	
func line_finished():
	print("end XXX =")
	stopFlapping()	

func startFlapping():
	texture.pause = false
	texture.oneshot = false
	
func stopFlapping():
	texture.pause = false
	texture.oneshot = true
	#texture.current_frame = 0
