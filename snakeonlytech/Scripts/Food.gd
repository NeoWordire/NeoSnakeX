extends Area2D
class_name Food, "res://Assets/Textures/apple.png"

var truepos : Vector2

export (float) var respawntime = 2;
var respawntimer = Timer.new();

func _ready():
	#respawntimer.connect("timeout",self,"fire_cooled_off")
	respawntimer.one_shot = true
	add_child(respawntimer)
	respawntimer.connect("timeout",self,"respawn")
	pass
	
	
func respawn():
	if (GlobalSnakeVar.paused):
		return
	truepos.x = GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.width/GlobalSnakeVar.tilesize - 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	truepos.y = GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.height/GlobalSnakeVar.tilesize- 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize
	if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] != 0:
		ate_food();
		return

	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] = 2
	position = truepos
	pass
	
func ate_food():
	print("move food")
	respawntimer.wait_time = respawntime
	respawntimer.start()
	position = Vector2(-99, -99)

