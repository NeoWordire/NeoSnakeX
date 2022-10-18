extends KinematicBody2D
class_name Bullet, "res://Assets/Textures/icon.png"

signal bullet_moved(bullet,pos)

#class_name Bullet
var truepos : Vector2
var truedir = GlobalSnakeVar.EAST
var pastpos : Vector2
var bullet_interp_per_second

func setup(pos, dir):
	pastpos = pos
	position = pos
	
	truepos = GlobalSnakeVar.posdir2pos(pos,dir%4) 
	#emit_signal("bullet_moved", truepos)
	#pastpos =#	polygon = PoolVector2Array([
#		Vector2(0,0),
#		Vector2(0,4),
#		Vector2(4,4),
#		Vector2(4,0)])
#	var area2d = Area2D
#	var collisionpoly = RectangleShape2D
	truedir = dir
##			bulletpoly.position = posdir2pos(snakes[x]["truecords"][0], snakes[x]["tilerot"][0])
	#color = Color (0,0,0,1)	
	#nextpos = GlobalSnakeVar.posdir2pos(truepos, truedir)

func _ready():
	pass

var lerptime = 0.1
var updatetime = 999
func update_display():
	if GlobalSnakeVar.paused:
		lerptime = 0
		return

	#if (lerptime >= 1.0):
	#	lerptime -= 1.0
	#print("TEST", lerptime*bullet_interp_per_second)
	#print(lerppos)
	var lerppos = pastpos.linear_interpolate(truepos, lerptime)
	position = lerppos
 

func step_simulation():
	#print("true", truepos)
	pastpos = truepos
	truepos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	if truepos.x < 0 || truepos.x >= GlobalSnakeVar.width || truepos.y < 0 || truepos.y >= GlobalSnakeVar.height:
		#self.disconnect("bullet_moved", get_parent(), "check_bullet")
		remove_bullet()
		return
	#emit_signal("bullet_moved", self, truepos)
	#print(lerptime)
	lerptime = 0.0
	#nextpos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	pass

func remove_bullet():
	if (get_parent() != null):
		get_parent().remove_child(self)
	GlobalSnakeVar.bullets.erase(self)
	queue_free()

func _physics_process(delta):
	#if lerptime <= 1.0:
	lerptime += delta * ( 120.0 / (120 * GlobalSnakeVar.g_bullet_moves_per_second))
	update_display()
	pass
	
func _process(delta):
	pass
