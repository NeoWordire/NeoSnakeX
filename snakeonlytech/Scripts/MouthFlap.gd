extends Sprite


# Declare member variables here. Examples:
func event_started(line, line2):
		print(line,line2)
		if(line == "text"):
				startFlapping()
		pass

func event_ended(line):
		print(line)
		#if(line == "text"):
		stopFlapping()
		#pass

# Called when the node enters the scene tree for the first time.
func _ready():
		get_parent().get_parent().get_parent().connect("event_start", self, "event_started")
		get_parent().get_parent().get_parent().connect("text_complete", self, "event_ended")
		stopFlapping()
		pass # Replace with function body.

# Declare member variables here. Examples:

func startFlapping():
		texture.pause = false
		texture.oneshot = false

func stopFlapping():
		texture.pause = false
		texture.oneshot = true
		#texture.current_frame = 0
