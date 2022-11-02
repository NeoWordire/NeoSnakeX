extends Area2D
class_name Food, "res://Assets/Textures/apple.png"


export (float) var respawntime = 2.0;
var respawntimer = Timer.new();

func _ready():
	respawntimer.one_shot = true
	add_child(respawntimer)
	respawntimer.connect("timeout",self,"respawn")
	pass
	
	
func respawn():
	if (GlobalSnakeVar.paused):
		return
	var temppos = Vector2(GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.width/GlobalSnakeVar.tilesize - 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize,
			GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.height/GlobalSnakeVar.tilesize- 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize)
	#if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] != 0:
	if GlobalSnakeVar.g_boardSprites.has(temppos):
		ate_food();
		return

	#GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] = 2
	position = temppos
	pass
	
func ate_food():
	#print("move food")
	SoundPlayer.play_sound(SoundPlayer.SFXFOODPICKUP)
	respawntimer.wait_time = respawntime
	respawntimer.start()
	position = Vector2(-99, -99)

