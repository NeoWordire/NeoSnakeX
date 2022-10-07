extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float, 0.1, 100) var period = 1.5
export(float) var amplitude = 20

var elapsed: float = 0
var startingPosition: Vector2


func _ready():
	startingPosition = rect_position
	pass

func _process(delta):
	rect_position.y = startingPosition.y + (amplitude * sin(elapsed * ((2 * PI) / period)))
	rect_position.x = startingPosition.x + (amplitude * cos(elapsed * ((2 * PI) / period)))
	elapsed += delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pressed():
	get_tree().change_scene("res://mainmenu.tscn");
#	pass
