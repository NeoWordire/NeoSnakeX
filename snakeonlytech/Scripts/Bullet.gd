extends Polygon2D
class_name Bullet, "res://Assets/Textures/icon.png"

signal bullet_moved(bullet,pos)

#class_name Bullet
var truepos : Vector2
var truedir = GlobalSnakeVar.EAST
var pastpos : Vector2
var bullet_interp_per_second

func setup(pos, dir):
	position = pos
	truepos = pos
	emit_signal("bullet_moved", truepos)
	pastpos = pos
	polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,4),
		Vector2(4,4),
		Vector2(4,0)])
	truedir = dir
##			bulletpoly.position = posdir2pos(snakes[x]["truecords"][0], snakes[x]["tilerot"][0])
	color = Color (0,0,0,1)	
	#nextpos = GlobalSnakeVar.posdir2pos(truepos, truedir)

func _ready():
	pass

var lerptime = 0.0
var updatetime = 999
func update_display():
	if GlobalSnakeVar.paused:
		lerptime = 0
		return
	var temporg = pastpos
	temporg.x += 2
	temporg.y += 2
	var tempnew = truepos
	tempnew.x += 2
	tempnew.y += 2

	#if (lerptime >= 1.0):
	#	lerptime -= 1.0
	#print("TEST", lerptime*bullet_interp_per_second)
	#print(lerppos)
	var lerppos = temporg.linear_interpolate(tempnew, lerptime)
	position = lerppos
 
func step_simulation():
	#print("true", truepos)
	pastpos = truepos
	truepos = GlobalSnakeVar.posdir2pos(truepos, truedir)
	if truepos.x < 0 || truepos.x >= GlobalSnakeVar.width || truepos.y < 0 || truepos.y >= GlobalSnakeVar.height:
		#self.disconnect("bullet_moved", get_parent(), "check_bullet")
		remove_bullet()
		return
	emit_signal("bullet_moved", self, truepos)
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
	if lerptime <= 1.0:
		lerptime += delta * GlobalSnakeVar.g_bullet_moves_per_second - GlobalSnakeVar.g_bullet_moves_per_second/60
	update_display()
	pass
	
func _process(delta):
	pass
