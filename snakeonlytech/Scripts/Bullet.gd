extends Area2D
class_name Bullet, "res://Assets/Textures/icon.png"
func get_class(): return "Bullet"

# signal bullet_moved(bullet,pos)

var truepos : Vector2
var truedir = GlobalSnakeVar.EAST
var pastpos : Vector2
var parent_player
var localMps

func _ready():
	position += Vector2(8,0).rotated(rotation)
	localMps = get_parent().get_parent().ModConditions["BulletMps"]
	connect("area_entered", get_parent(),"bullet_area_entered", [self])
	pass

func _physics_process(delta): 
	position += Vector2(localMps,0).rotated(rotation)*delta*8
	pass
	
func _process(_delta):
	pass
