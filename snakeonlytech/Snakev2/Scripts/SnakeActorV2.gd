extends Node2D
func get_class(): return "SnakeActor"
const customAStar = preload("res://Scripts/customAStar.gd")
const Bullet = preload("res://Snakev2/Bullet.tscn")
var SnakeBodyMainSprite = load("res://Snakev2/SnakeBodySegmentv2.tscn")
var SnakeBodyDeadSprite = load("res://Snakev2/SnakeBodyDeadParticle.tscn")

signal snake_died(player)

# Declare member variables here. Examples:
# var a = 2
# var b = "text

const tilesize = 8

var reqdir = GlobalSnakeVar.EAST
var truedir
var reqshoot
export (int) var player = 0
export (int, "player","ai") var HumanOrCPU
export (Texture) var bodytex
export (Texture) var headtex
export (bool) var flipDir = false
var inputqueue = []
var snakecap = 5
var spawnposarray = []
var spawnrotarray = []

func get_input():
	var oldinputmask = 0;
	# iterate over inputqueue and collect all bits 
	for i in inputqueue:
		oldinputmask |= 1 << i
	
	if Input.is_action_pressed("ui_right"):
		if oldinputmask & GlobalSnakeVar.EASTBIT == 0:
			inputqueue.append(GlobalSnakeVar.EAST)
	else:
		inputqueue.erase(GlobalSnakeVar.EAST)
	if Input.is_action_pressed("ui_left"):
		if oldinputmask & GlobalSnakeVar.WESTBIT == 0:
			inputqueue.append(GlobalSnakeVar.WEST)
	else:
		inputqueue.erase(GlobalSnakeVar.WEST)
	if Input.is_action_pressed("ui_up"):
		if oldinputmask & GlobalSnakeVar.NORTHBIT == 0:
			inputqueue.append(GlobalSnakeVar.NORTH)
	else:
		inputqueue.erase(GlobalSnakeVar.NORTH)
	if Input.is_action_pressed("ui_down"):
		if oldinputmask & GlobalSnakeVar.SOUTHBIT == 0:
			inputqueue.append(GlobalSnakeVar.SOUTH)
	else:
		inputqueue.erase(GlobalSnakeVar.SOUTH)
		
	if (inputqueue.size()!= 0):
		if ((truedir + 2)%4 != inputqueue[-1]):
			reqdir = inputqueue[-1]
	#else:
		#eqdir = truedir
		#inputqueue = oldinputmask
	reqshoot = false
	if Input.is_action_pressed("ui_accept"):
		reqshoot = true

# Called when the node enters the scene tree for the first time.
func _ready():
	for ray in get_node("Head/NavObj").get_children():
		if (ray.get_class() == "RayCast2D"):
			ray.add_exception(get_node("Head/Segment/SegmentHitbox"))
			#ray.add_exception(get_node("Head/NavObj/Front33Area"))
	$Head.position = $Head.global_position
	for seg in $Body.get_children():
		seg.position = seg.global_position
	position = Vector2(0,0)
	if (flipDir):
		flip_snake()
	spawnposarray.append($Head.position)
	spawnrotarray.append($Head.rotation)
	$Head.texture = headtex
	
	for segment in 5:
		var newpos = spawnposarray[segment]
		var newrot = spawnrotarray[segment]
		if (flipDir):
			newpos.x += 8
		else:
			newpos.x -= 8
		spawnposarray.append(newpos)
		spawnrotarray.append(newrot)
	pass

func respawn():
	if (flipDir):
		reqdir = GlobalSnakeVar.DIRS.WEST
	else:
		reqdir = GlobalSnakeVar.DIRS.EAST
	truedir = reqdir
	for segment in range(snakecap,spawnposarray.size()-1):
		grow_tail(spawnposarray[segment], 0)
		snakecap += 1
		pass
	assert(snakecap >= 5)	
	while (snakecap > 5): # dynamic
		shrink_end()
	assert(snakecap == 5)
	$Head.position = spawnposarray[0]
	$Head.rotation = spawnrotarray[0]
	#for segment in range(1,spawnposarray.size()):
	for segment in range(1,snakecap+1):
		$Body.get_child(segment-1).position = spawnposarray[segment]
		$Body.get_child(segment-1).rotation = spawnrotarray[segment]
		$Body.get_child(segment-1).texture = bodytex
	
func setupRound():
	#assert(get_parent().currentBattleState == get_parent().BATTLESTATE.STATE_INIT)
	respawn()
	
func _process(delta):
	if (!HumanOrCPU):
		get_input()
	
func flip_snake():
	var count = $Body.get_child_count() -1
	var last = $Body.get_child(count).position
	$Body.get_child(count).position = $Head.position
	$Head.position = last
	for segid in range(0,(count)/2.0):
		print("swap, ", segid, count - segid-1)
		var temp = $Body.get_child(count - segid-1).position
		$Body.get_child(count - segid-1).position = $Body.get_child(segid).position
		$Body.get_child(segid).position = temp
	truedir = GlobalSnakeVar.DIRS.WEST
	$Head.rotation = deg2rad(180)
	for seg in $Body.get_children():
		seg.rotation = deg2rad(180)
	pass
	

func ai_ray_input():
	var rays = {}
	for ray in $Head/NavObj.get_children():
		if (ray.get_class() != "RayCast2D"):
			continue
		#ray.force_raycast_update()
		rays[ray.name] = {"hit":ray.get_collider(), "pos":ray.get_collision_point()}

	var valid_moves = {}
	var centdistance = $Head.position.distance_to(rays["CenterStepRay"]["pos"])
	#print(player," dist =", centdistance)
	if !rays["CenterStepRay"]["hit"]:
		var value = 500
		valid_moves[truedir] = value
	elif rays["CenterStepRay"]["hit"].name == "Food":
		var value = 1000
		valid_moves[truedir] = value
	elif centdistance > 5*tilesize:
		valid_moves[truedir] = centdistance*2
	
	reqshoot = false
	if(rays["CenterStepRay"]["hit"] && rays["CenterStepRay"]["hit"].get_parent()&& rays["CenterStepRay"]["hit"].get_parent().get_parent()):
		if(rays["CenterStepRay"]["hit"].get_parent().get_parent().get_class() == "SnakeSegment"):
			reqshoot = true
	
	if !rays["LeftStepRay"]["hit"]:
		var value = GlobalSnakeVar.g_rng.randi_range(0,10)
		valid_moves[(truedir + 3)%4] = value
		
	elif $Head.position.distance_to(rays["LeftStepRay"]["pos"]) > 6:
		valid_moves[(truedir + 3)%4] = 1

	if !rays["RightStepRay"]["hit"]:
		var value = GlobalSnakeVar.g_rng.randi_range(0,10)
		valid_moves[(truedir + 1)%4] = value
	elif $Head.position.distance_to(rays["RightStepRay"]["pos"]) > 6:
		valid_moves[(truedir + 1)%4] = 1

	var foodpos = get_parent().get_node("Food").position
	foodpos += Vector2(4,4)
	for key in valid_moves:
		if key == GlobalSnakeVar.NORTH:
			if foodpos.x == $Head.position.x:
				if foodpos.y < $Head.position.y:
					valid_moves[key] = 999999999
		if key == GlobalSnakeVar.SOUTH:
			if foodpos.x == $Head.position.x:
				if foodpos.y > $Head.position.y:
					valid_moves[key] = 999999999
		if key == GlobalSnakeVar.EAST:
			if foodpos.y == $Head.position.y:
				if foodpos.x > $Head.position.x:
					valid_moves[key] = 999999999
		if key == GlobalSnakeVar.WEST:
			if foodpos.y == $Head.position.y:
				if foodpos.x < $Head.position.x:
					valid_moves[key] = 999999999
#		print("head = ", $Head.position.x, "vs food",get_parent().get_node("Food").position.x)
						

	var bestrank = -9999
	var bestans = GlobalSnakeVar.NODIR
	for key in valid_moves:
		if valid_moves[key] > bestrank:
			bestrank = valid_moves[key]
			bestans = key
	print(player, ":", valid_moves,bestans)
	if (bestans == GlobalSnakeVar.NODIR):
		reqdir = truedir
		#breakpoint
	else:
		reqdir = bestans


func grow_tail(pos,rot):
	var new = SnakeBodyMainSprite.instance()
	new.position = pos
	new.rotation = rot
	new.texture = bodytex

	$Body.add_child(new)
	new.name = String(get_index())

func shoot_bullet():
	if (get_parent().ModConditions["ShootDisabled"]):
		return
	var bullet = Bullet.instance()
	bullet.position = $Head.position
	bullet.rotation = $Head.rotation	
	add_child(bullet)
	$shootCoolDown.start(get_parent().ModConditions["ShootCooldown"])
	pass

var iterateNext = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (!HumanOrCPU):
		get_input()
	if !iterateNext:
		return
	
	
	iterateNext = false
	if (HumanOrCPU):
		ai_ray_input()
	var prevpos = $Head.position
	var prevrot = $Head.rotation
	var tailpos = $Body.get_child($Body.get_child_count()-1).position
	var tailrot = $Body.get_child($Body.get_child_count()-1).rotation
	for childx in $Body.get_child_count():
		var temppos = $Body.get_child(childx).position
		var temprot = $Body.get_child(childx).rotation
		$Body.get_child(childx).position = prevpos
		$Body.get_child(childx).rotation = prevrot
		prevpos = temppos
		prevrot = temprot
		
	if (reqdir == GlobalSnakeVar.NORTH):
		$Head.position.y -= tilesize
		$Head.rotation = deg2rad(270)
	if (reqdir == GlobalSnakeVar.EAST):
		$Head.position.x += tilesize
		$Head.rotation = 0
	if (reqdir == GlobalSnakeVar.SOUTH):
		$Head.position.y += tilesize
		$Head.rotation = deg2rad(90)
	if (reqdir == GlobalSnakeVar.WEST):
		$Head.position.x -= tilesize
		$Head.rotation = deg2rad(180)
	$Body.get_child(0).rotation = $Head.rotation
	truedir = reqdir
	if reqshoot && $shootCoolDown.time_left == 0.0:
		shoot_bullet()
	if snakecap > $Body.get_child_count():
		grow_tail(tailpos,tailrot)

func shrink_end():
	print("Shrink")
	snakecap -= 1
	var endseg = get_node("Body").get_child(get_node("Body").get_child_count()-1)
	get_node("Body").remove_child(endseg)
	endseg.queue_free()


func got_shot(segment):
	print("got shot")
	if(segment.name == "Head"):
		#PLAY ARMORTINKNOISE
		pass
	else:
		var snakenode = segment.get_parent().get_parent()
		print("Spawn dead spinner at ", segment.position)
		var dead = SnakeBodyDeadSprite.instance()
		dead.position = segment.position
		dead.texture = snakenode.bodytex
		add_child(dead)
		snakenode.shrink_end()

func _front33_entered_area(area):
	#print("XXXXXXX")
	pass

func _head_entered_area(area):
	$Head.raise()
	if (area.name == "SegmentHitbox"):
		emit_signal("snake_died", player)
	if area.name == "Walls":
		emit_signal("snake_died", player)
	#breakpoint
	#emit_signal("snake_died", player)

func bullet_area_entered(area, bullet):
	if area.get_parent().get_parent().get_class() == "SnakeSegment":
		if(area.get_parent().get_parent().get_parent().get_class() == "SnakeActor"):
			if(area.get_parent().get_parent().get_parent().player == player):
				return
			else:
				got_shot(area.get_parent().get_parent())
		if(area.get_parent().get_parent().get_parent().get_parent().get_class() == "SnakeActor"):
			if(area.get_parent().get_parent().get_parent().get_parent().player == player):
				return
			else:
				got_shot(area.get_parent().get_parent())
	bullet.queue_free()
