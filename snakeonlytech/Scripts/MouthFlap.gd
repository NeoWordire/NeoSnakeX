extends Sprite


# Declare member variables here. Examples:
func event_started(line, line2):
		if(line == "text" && line2["character"] == get_parent().character_data.file):
			startFlapping()
		pass

func event_ended(line):
		#if(line == "text"):
		stopFlapping()
		#pass

# Called when the node enters the scene tree for the first time.
func _ready():
		get_parent().get_parent().get_parent().connect("event_start", self, "event_started")
		get_parent().get_parent().get_parent().connect("text_complete", self, "event_ended")
		 #character-1666848962.json
		stopFlapping()
		pass # Replace with function body.

# Declare member variables here. Examples:

func startFlapping():
		texture.pause = false
		texture.oneshot = false

func stopFlapping():
		texture.oneshot = true
		texture.current_frame = 0
