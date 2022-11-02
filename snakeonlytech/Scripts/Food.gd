extends Area2D
class_name Food, "res://Assets/Textures/apple.png"


export (float) var respawntime = 2.0;

var spawncenter = Vector2.ZERO
var spawnextents = Vector2.ZERO

func _ready():
	spawncenter = $SpawnArea/CollisionShape2D.global_position
	spawnextents = $SpawnArea/CollisionShape2D.shape.get_extents()
	$Timer.one_shot = true
	$Timer.connect("timeout",self,"respawn")
	disappear_food()
	pass
	
	
func respawn():
	var newpos = spawncenter
	newpos.x += (GlobalSnakeVar.g_rng.randi_range(-spawnextents.x-16, spawnextents.x-16)/8)*8
	newpos.y += (GlobalSnakeVar.g_rng.randi_range(-spawnextents.y-16, spawnextents.y-16)/8)*8
	position = newpos
	print("timer up")
	$CollisionShape2D.disabled = false
	visible = true
#	if (GlobalSnakeVar.paused):
#		return
#	var temppos = Vector2(GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.width/GlobalSnakeVar.tilesize - 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize,
#			GlobalSnakeVar.g_rng.randi_range(GlobalSnakeVar.borderintiles*2, GlobalSnakeVar.height/GlobalSnakeVar.tilesize- 2*GlobalSnakeVar.borderintiles)*GlobalSnakeVar.tilesize)
#	#if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] != 0:
#	if GlobalSnakeVar.g_boardSprites.has(temppos):
#		ate_food();
#		return
#
#	#GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truepos)] = 2
#	position = temppos
	pass
func disappear_food():
	$Timer.wait_time = respawntime
	$Timer.start()
	$CollisionShape2D.disabled = true
	visible = false

func ate_food():
	#print("move food")
	SoundPlayer.play_sound(SoundPlayer.SFXFOODPICKUP)
	disappear_food()



func _on_Food_area_entered(area):
	if (area.get_parent().get_parent().name == "Head"):
		ate_food()
		print("ate food",area.get_parent().get_parent().name)
	pass # Replace with function body.
