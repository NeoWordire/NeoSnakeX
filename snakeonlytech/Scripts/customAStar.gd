extends AStar2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _estimate_cost(u, v):
	#var dist = (get_point_position(u) - get_point_position(v)).abs()
	#return dist.x + dist.y
	var xcost = abs((get_point_position(u).x - get_point_position(v).x))
	var ycost = abs((get_point_position(u).y - get_point_position(v).y))
	return xcost + ycost

func _compute_cost(u, v):
	return _estimate_cost(u, v)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
