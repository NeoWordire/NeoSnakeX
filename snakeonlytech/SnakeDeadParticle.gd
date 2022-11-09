extends Sprite


# Declare member variables here. Examples:
# var a = 2
var velocity
var life = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	life = 0
	velocity = Vector2(10,-50)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life += delta
	position.y += velocity.y * delta
	velocity.y += 150 * delta
	rotation += delta * PI
	#modulate.a -= GlobalSnakeVar.g_snake_moves_per_second*delta):
	if (life > 2.0):
		get_parent().remove_child(self)
		queue_free()
	pass
