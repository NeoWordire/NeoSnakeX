extends Polygon2D
class_name Bullet, "res://Assets/Textures/icon.png"

#class_name Bullet
var truepos : Vector2
var truedir = GlobalSnakeVar.EAST
var nextpos : Vector2
var bullet_interp_per_second

func setup(pos,steps_a_second):
	self.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,4),
		Vector2(4,4),
		Vector2(4,0)])
	self.position = pos
##			bulletpoly.position = posdir2pos(snakes[x]["truecords"][0], snakes[x]["tilerot"][0])
	self.color = Color (0,0,0,1)	
	bullet_interp_per_second = steps_a_second
#
func _ready():
	pass

var lerptime = 0.0
var updatetime = 999
func update_display():
	position = truepos.linear_interpolate(nextpos, lerptime)
	

func step_simulation():
	truepos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	nextpos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	pass

func _physics_process(delta):
#	lerptime += delta * bullet_interp_per_second
#	print(lerptime)
#	if (lerptime > 1.0):
#		lerptime = 0
#	update_display()
	pass
	
func _process(delta):
	lerptime += delta * bullet_interp_per_second
	if (lerptime >= 1.0):
		lerptime -= 1.0
	update_display()
	pass
	#updatetime += delta

	pass
