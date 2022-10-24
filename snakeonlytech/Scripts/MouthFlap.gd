extends Sprite


# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var lastline = "" 

func _on_YarnRunner_line_emitted(line):
	var temp = line.trim_prefix(self.name + ":")
	if (temp != line && lastline == ""):
		startFlapping()
	lastline = line
	pass

func startFlapping():
	texture.pause = false
	texture.oneshot = false
	
func stopFlapping():
	texture.pause = false
	texture.oneshot = true
	#texture.current_frame = 0
	

func _on_YarnDisplay_line_started():
	if lastline:
		var temp = lastline.trim_prefix(self.name + ":")
		if (temp != lastline):
			startFlapping()
		else :
			stopFlapping()
	pass # Replace with function body.


func _on_YarnDisplay_line_finished():
	stopFlapping()
	pass # Replace with function body.
	
func _on_MenuSelectControl_finish_line_early():
	stopFlapping()
	pass # Replace with function body.
