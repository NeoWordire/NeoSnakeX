extends Label

# Declare member variables here. Examples:

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var string = "Display FPS: " + String(Engine.get_frames_per_second()) + "\n"
	if Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000 > 1.0:
		string += "Engine FPS (capped to 60): " + String(1000.0/(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.0))+ "\n"
		if 1000.0/(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.0) < 60.0:
			add_color_override("font_color", Color(1,0,0))
	string += "snake: " + String(GlobalSnakeVar.g_time_between_snake/1000.0) + ", " + String(GlobalSnakeVar.g_counterlastsnake) + "\n"
	string += "bullet: " + String(GlobalSnakeVar.g_time_between_bullet/1000.0) + "\n"
	if (GlobalSnakeVar.g_counterlastsnake != 60 / GlobalSnakeVar.g_snake_moves_per_second && GlobalSnakeVar.g_counterlastsnake != 0 ):
		add_color_override("font_color", Color(1,0,0))
	text = string
