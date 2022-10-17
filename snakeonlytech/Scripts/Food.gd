extends Sprite
class_name Food, "res://Assets/Textures/apple.png"

var truepos : Vector2

func ready_():
	pass
	
#func setup():
#	polygon = PoolVector2Array([
#		Vector2(0,0),
#		Vector2(0,GlobalSnakeVar.tilesize),
#		Vector2(GlobalSnakeVar.tilesize,GlobalSnakeVar.tilesize),
#		Vector2(GlobalSnakeVar.tilesize,0)
#	])
#	texture = load("res://.import/apple.png-33dbe4c507a49239fb8f4aae8c7dcd32.stex")
	#position = Vector2(-100,-100)
	
func move_food():
	print("move food")
	truepos.x = GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.width/GlobalSnakeVar.tilesize - 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	truepos.y = GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.height/GlobalSnakeVar.tilesize- 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] != 0:
		move_food();
		return
	#if(oldpos.x != -100 && oldpos.y != -100):
	#	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(oldpos)] = 0
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] = 2
	var offsetpos = truepos
	offsetpos.x += 4
	offsetpos.y += 4
	position = offsetpos
