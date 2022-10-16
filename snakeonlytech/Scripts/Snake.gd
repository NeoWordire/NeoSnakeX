extends Node2D
class_name Snake, "res://Assets/Textures/icon.png"

#class_name Bullet
var sprites = []
var truecords = [] 
var tilerot = []
var snakelen = 0 
var snakecap = 5
var truedir = GlobalSnakeVar.EAST
var reqdir = GlobalSnakeVar.EAST
var inputqueue = []
var inputshoot = false
#var bulletsprite = [],
#var bulletpos = [],
#var bulletrot = [],
var futureheadpos : Vector2
func setup(pos, tex, headtex):

	var poly = Polygon2D.new()
	poly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,0)])
	poly.position = pos
	poly.texture = headtex
	#poly.texture = tex
	truecords.append(pos)
	sprites.append(poly)
	add_child(poly)
	for i in snakecap:
		step_simulation()
	return 
##			bulletpoly.position = posdir2pos(snakes[x]["truecords"][0], snakes[x]["tilerot"][0])

func _ready():
	pass

func step_simulation():
	var died = false
	var oldtailforgrow = truecords[-1]
		#grow
	body_follow_head()
	if (!move_head()):
		died = true
		print("DIED")
	if snakecap > sprites.size():
		grow(oldtailforgrow, truedir)
	#futureheadpos = GlobalSnakeVar.posdir2pos(truecords[0], truedir)
	return died
	pass

func _process(delta):
	get_input()

func _physics_process(delta):
	update_display()
	#
	#updatetime += delta
	#if (updatetime*GlobalSnakeVar.moves_per_second >= 1.0):
	#	updatedpos(GlobalSnakeVar.EAST)
	#	updatetime = 0
	pass


var lerptime = 0
var updatetime = 999
func update_display():
	for s in sprites.size():
		sprites[s].position = truecords[s]

func get_input():
	# velocity = Vector2()
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
	inputshoot = false
	if Input.is_key_pressed(KEY_CONTROL):
		inputshoot = true

func move_head():
	truedir = reqdir
	var goingto = GlobalSnakeVar.posdir2pos(truecords[0], truedir)
	if (GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(goingto)] == 1):
		return false
	truecords[0] = goingto
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[0])] = 1
	return true

func body_follow_head():
	if sprites.size() <= 1:
		GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[0])] = 0
		return
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[-1])] = 0
	for s in (sprites.size()-1):
		var inverse = sprites.size() - s - 1
		truecords[inverse] = truecords[inverse-1] 
		#snakes[i]["tilerot"][inverse] = snakes[i]["tilerot"][inverse - 1]
		GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[inverse])] = 1
		#tile_draw_snake_flag_from_true(i, inverse)
		
func grow(tailpos, rot):
	var poly = Polygon2D.new()
	poly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,GlobalSnakeVar.tilesize),
		Vector2(GlobalSnakeVar.tilesize,0)
	])
	poly.set_texture(load("res://.import/snake_box.png-c732c474a5e44921cf1bbd0daf4f61df.stex"))
	#poly.color = Color(0, 1, 0, 1)
	sprites.append(poly)
	truecords.append(tailpos)

	#snakes[i]["tilerot"].append(rot)
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(tailpos)] = 1
	#tile_draw_snake_flag_from_true(i, snakes[i]["snakelen"])
	add_child(poly)
	#colmap[pos2index(snakes[i]["truecords"][-1])] = 1
	#snakes[i]["snakelen"] += 1
