extends Polygon2D
class_name Food, "res://Assets/Textures/icon.png"

func ready_():
	pass
	
func setup():
	polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,0)
	])
	texture = load("res://.import/apple.png-33dbe4c507a49239fb8f4aae8c7dcd32.stex")
	position = Vector2(-100,-100)
	
func move_food():
	var oldpos = position
	position.x = GlobalSnakeVar.rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.width/GlobalSnakeVar.tilesize - 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	position.y = GlobalSnakeVar.rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.height/GlobalSnakeVar.tilesize- 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(position)] != 0:
		move_food();
		return
	if(oldpos.x != -100 && oldpos.y != -100):
		GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(oldpos)] = 0
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(position)] = 2
