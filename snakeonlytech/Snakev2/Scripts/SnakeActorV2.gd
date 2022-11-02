extends Node2D
func get_class(): return "SnakeActor"
const customAStar = preload("res://Scripts/customAStar.gd")
var SnakeBodyMainSprite = load("res://Snakev2/SnakeBodySegmentv2.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const tilesize = 8

var reqdir
var truedir
export (int) var player = 0
export (Texture) var bodytex
export (Texture) var headtex
var inputqueue = []
var rays = [Vector2(0,-8),Vector2(8,0),Vector2(0,8),Vector2(-8,0)]

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
		reqdir = inputqueue[-1]
	else:
		reqdir = truedir

# Called when the node enters the scene tree for the first time.
func _ready():
	reqdir = GlobalSnakeVar.EAST
	truedir = reqdir
	for ray in get_node("Head/NavObj").get_children():
		if (ray.get_class() == "RayCast2D"):
			ray.add_exception(get_node("Head/Segment/SegmentHitbox"))
			ray.add_exception(get_node("Head/NavObj/Front33Area"))
#	get_node("Head/ForwardBox").enabled = false
#	get_node("Head/LeftStepRay").add_exception(get_node("Head/Area2D"))
#	get_node("Head/RightStepRay").add_exception(get_node("Head/Area2D"))
#
	get_node("Head").texture = headtex
	for segment in get_node("Body").get_children():
		segment.texture = bodytex

func _process(delta):
	#get_input()
	pass
	
func update_rays(dir):
	#get_node("Head/CenterStepRay").cast_to = rays[dir]
	#get_node("Head/LeftStepRay").cast_to = rays[(dir+3)%4]
	#get_node("Head/RightStepRay").cast_to = rays[(dir+1)%4]
	pass

func ai_ray_input():
	get_node("Head/NavObj/CenterStepRay").force_raycast_update()
	var rayhit = get_node("Head/NavObj/CenterStepRay").get_collider()
	get_node("Head/NavObj/LeftStepRay").force_raycast_update()
	var rayhitleft = get_node("Head/NavObj/LeftStepRay").get_collider()
	get_node("Head/NavObj/RightStepRay").force_raycast_update()
	var rayhitright = get_node("Head/NavObj/RightStepRay").get_collider()
	#if rayhitleft:
		#print("left git ")
	#if rayhitright:
		#print("right git ")
	var valid_moves = {}
	if !rayhit:
		var 	value = 98
		for i in get_node("Head/NavObj/Front33Area").get_overlapping_areas():
			value -= 32
			print("seen value", value)
		valid_moves[truedir] = value
		
		#print("center hit ", rayhit.get_parent().name)
	if !rayhitleft:
		var value = GlobalSnakeVar.g_rng.randi_range(0,100)
		valid_moves[(truedir + 3)%4] = value
	if !rayhitright:
		var value = GlobalSnakeVar.g_rng.randi_range(0,100)
		valid_moves[(truedir + 1)%4] = value
	
	var bestrank = -9999
	var bestans = GlobalSnakeVar.NODIR
	for key in valid_moves:
		if valid_moves[key] > bestrank:
			bestrank = valid_moves[key]
			bestans = key
	print(valid_moves,bestans)
	if (bestans == GlobalSnakeVar.NODIR):
		reqdir = truedir
		breakpoint
	else:
		reqdir = bestans
	
#		var hitarea = get_node("Head/CenterStepRay").get_collider()
#		if (hitarea.get_parent().get_class() == "SnakeSegment"):
#			var hitsegment = hitarea.get_parent()
#			var hitsnake = hitsegment
#			while hitsnake.get_class() != "SnakeActor":
#				hitsnake = hitsnake.get_parent()
#			var hitdistance = get_node("Head").position.distance_to(hitsegment.position)
#			print("hit node,",hitsegment.name)
#			print("distance = ", hitdistance)
#			print("hitsnake = ", hitsnake)
			

func grow_tail(pos):
	var new = SnakeBodyMainSprite.instance()
	new.position = pos
	new.texture = bodytex
	get_node("Body").add_child(new)
	new.name = String(get_index())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#get_input() ###### MAYBE?
	ai_ray_input()
	var prevpos = get_node("Head").position
	var tailpos = get_node("Body").get_child(get_node("Body").get_child_count()-1).position
#	for childx in range(get_node("Body").get_child_count() -1, -1, -1):
	for childx in get_node("Body").get_child_count():
		var temppos = get_node("Body").get_child(childx).position
		get_node("Body").get_child(childx).position = prevpos
		prevpos = temppos
	if (reqdir == GlobalSnakeVar.NORTH):
		get_node("Head").position.y -= tilesize
		get_node("Head").rotation = deg2rad(270)
	if (reqdir == GlobalSnakeVar.EAST):
		get_node("Head").position.x += tilesize
		get_node("Head").rotation = 0
	if (reqdir == GlobalSnakeVar.SOUTH):
		get_node("Head").position.y += tilesize
		get_node("Head").rotation = deg2rad(90)
	if (reqdir == GlobalSnakeVar.WEST):
		get_node("Head").position.x -= tilesize
		get_node("Head").rotation = deg2rad(180)
	get_node("Head")
	truedir = reqdir
#	if (reqdir == 0 || reqdir == 2):
#		grow_tail(tailpos)
		

func _front33_entered_area(area):
	#print("XXXXXXX")
	pass

func _head_entered_area(area):
	print(area.name)
	if (area.name == "SegmentHitbox"):
		breakpoint 
	if area.name == "Walls":
		breakpoint
	print(area)
	if (area.get_parent().get_class() == "TileMap"):
		pass
	#breakpoint	
	#get_node("Head").raise()
	#emit_signal("snake_died", player)

