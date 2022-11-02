extends Label

# Declare member variables here. Examples:

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var string = "Display FPS: " + String(Engine.get_frames_per_second()) + "\n"
	if Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS):
		string += "Engine FPS (capped to 60): " + String(1000.0/(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.0))+ "\n"
		if 1000.0/(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.0) < 60.0:
			add_color_override("font_color", Color(1,0,0))
	text = string
