extends Area2D
class_name Bullet, "res://Assets/Textures/icon.png"
func get_class(): return "Bullet"

signal bullet_moved(bullet,pos)

var truepos : Vector2
var truedir = GlobalSnakeVar.EAST
var pastpos : Vector2
var parent_player

func setup(pos, dir, player):
	parent_player = player
	pastpos = pos
	position = pos
	truepos = GlobalSnakeVar.posdir2pos(pos,dir%4) 
	truedir = dir

func _ready():
	pass

var lerptime = 0.1
var updatetime = 999
func update_display():
	if GlobalSnakeVar.paused:
		lerptime = 0
		return

	var lerppos = pastpos.linear_interpolate(truepos, lerptime)
	position = lerppos
 

func step_simulation():
	pastpos = truepos
	truepos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	if truepos.x < 0 || truepos.x >= GlobalSnakeVar.width || truepos.y < 0 || truepos.y >= GlobalSnakeVar.height:
		remove_bullet()
		return
	lerptime = 0.0
	pass

func remove_bullet():
	if (get_parent() != null):
		get_parent().remove_child(self)
	GlobalSnakeVar.bullets.erase(self)
	queue_free()

func _physics_process(delta):
	lerptime += delta * ( 120.0 / (120 * GlobalSnakeVar.g_bullet_moves_per_second))
	update_display()
	pass
	
func _process(delta):
	pass
