extends Sprite

var state = 0
# Declare member variables here. Examples:
# var a = 2
var life = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	life = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life += delta
	position.y -= delta * 40
	modulate.a -= GlobalSnakeVar.g_snake_moves_per_second*delta
	if (GlobalSnakeVar.g_snake_moves_per_second):
		if (life > 1.0):
			get_parent().remove_child(self)
			queue_free()
			pass
	pass
