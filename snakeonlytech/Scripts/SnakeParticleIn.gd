extends Sprite

var state = 0
# Declare member variables here. Examples:
# var a = 2
var life = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	life = 0
	state = 0
	modulate.a = 1.0
	pass # Replace with function body.

func set_state(newstate):
	state = newstate
	life = 0
	if (state == 1):
		life = 0
		modulate.a = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == 1:
		life += delta * GlobalSnakeVar.g_snake_moves_per_second
		#position.y -= delta * 40
		modulate.a += GlobalSnakeVar.g_snake_moves_per_second*delta
		if (GlobalSnakeVar.g_snake_moves_per_second):
			if (life > 1.0):
				set_state(0)
	pass
