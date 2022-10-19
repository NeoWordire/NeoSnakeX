extends Area2D
class_name Snake, "res://Assets/Textures/snake_head.png"
const Bullet = preload("res://Scripts/Bullet.gd")

signal snake_died(player)
signal ate_food()

#class_name Bullet
var sprites = []
var colshapes = []
var truecords = [] 
var tilerot = []
var snakecap = 5
var truedir = GlobalSnakeVar.NODIR
var reqdir = GlobalSnakeVar.NODIR
var inputqueue = []
var inputshoot = false

export (int, "player","ai") var HumanOrCPU

export (Texture) var bodytex
export (Texture) var headtex

export (Vector2) var startpos
export (GlobalSnakeVar.DIRS) var startRotation = GlobalSnakeVar.DIRS.EAST
#var bulletsprite = [],
#var bulletpos = [],
#var bulletrot = [],
var futureheadpos : Vector2
var _player
#var _notai

#var tex : ImageTexture

var bulletcooldown = Timer.new()
var canfire = true;

func get_class(): return "Snake"

func fire_cooled_off():
	canfire = true;

func setup(player):
	_player = player

	connect("ate_food", self, "ate_food_snake")
	#connect("ate_food", GlobalSnakeVar.foodpoly, "move_food")
	for bullet in GlobalSnakeVar.bullets:
		remove_child(bullet)
		bullet.queue_free()
	GlobalSnakeVar.bullets = []
	for sprite in sprites:
		remove_child(sprite)
		sprite.queue_free()
	for colshape in colshapes:
		remove_child(colshape)
		colshape.queue_free()
	colshapes = []
	sprites = [];
	truecords = []
	tilerot = []
	snakecap = 5
	bulletcooldown.connect("timeout",self,"fire_cooled_off")
	add_child(bulletcooldown)
	bulletcooldown.one_shot = true
	
	#build head specially
	var poly = Sprite.new()
	var colrect = CollisionShape2D.new()
	colrect.shape = CircleShape2D.new()
	colrect.shape.set_radius(1)
	#colrect.shape.set_extents(Vector2(GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2))
#	colrect.set_transform(Transform2D(
#		Vector2( GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2 ),
#		Vector2( GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2 ),
#		Vector2( 0, 0 )
#	))
	colrect.position.x = startpos.x + GlobalSnakeVar.tilesize/2
	colrect.position.y = startpos.y + GlobalSnakeVar.tilesize/2
	colshapes.append(colrect)
	add_child(colrect)
	#position = Vector2(0,0)
	####poly.position = GlobalSnakeVar.g_startpos[player]
	poly.texture = headtex
	truecords.append(startpos)
	#truecords.append(GlobalSnakeVar.g_startpos[player])
	
	reqdir = startRotation
	truedir = startRotation
	tilerot.append(truedir)
	
	sprites.append(poly)
	poly.position = Vector2(-100,-100)
	add_child(poly)
	for i in snakecap:
		play_movement()
	return 
##			bulletpoly.position = posdir2pos(snakes[x]["truecords"][0], snakes[x]["tilerot"][0])

func _ready():
	position = Vector2(0,0)
	pass

var lastrun = 0

func step_simulation():
	var time = OS.get_ticks_usec()
	GlobalSnakeVar.g_time_between_snake = time - lastrun
	lastrun = time
	if(HumanOrCPU == 0):
		get_input()
	else :
		get_input_ai()
	play_movement()
	pass
	
func play_movement():
	var died = false
	var oldtailforgrow = truecords[-1]
	var oldtailsrot = tilerot[-1]
		#grow
	truedir = reqdir
	tilerot[0] = truedir  #rotate old head to current dir
	body_follow_head()
	if (!move_head()):
		died = true
		return
		#print("DIED")
	if inputshoot && canfire:
		shoot(truecords[0],truedir)
	if snakecap > sprites.size():
		grow(oldtailforgrow, oldtailsrot)
	#futureheadpos = GlobalSnakeVar.posdir2pos(truecords[0], truedir)
	for x in colshapes.size():
		colshapes[x].position.x = truecords[x].x + GlobalSnakeVar.tilesize/2
		colshapes[x].position.y = truecords[x].y + GlobalSnakeVar.tilesize/2
	return died

func _process(delta):
	if (HumanOrCPU==0):
		get_input()

func _physics_process(delta):
	#update_display()
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
		tile_draw_snake_flag_from_true(s)

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
	if Input.is_key_pressed(KEY_CONTROL) ||  Input.is_action_pressed("ui_accept"):
		inputshoot = true

func get_input_ai():
	var currentdir = truedir
	var goalpos = GlobalSnakeVar.foodpoly.truepos
	var legalmoves = []
	var legalfoodrank = []
	var legalfloodrank = []
	var counts = []
	for x in 4:
		var testpos = GlobalSnakeVar.posdir2pos(truecords[0], x)
		if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(testpos)] != 1:
			legalmoves.append(x)
			#legalrank.append(1 50-abs(testpos.distance_to(Vector2(width/2,height/2))))
			#Vector2(0,0)
			#legalfoodrank.append(Vector2(0,0).distance_to(Vector2(width,height))
	#				- (testpos.distance_to(foodpoly.position)))
			var value = (Vector2(0,0).distance_to(Vector2(GlobalSnakeVar.width,GlobalSnakeVar.height)) - testpos.distance_to(goalpos))/2
			var newmap = GlobalSnakeVar.colmap.duplicate()
			if GlobalSnakeVar.g_numplayers == 2:
				var enemyindex = (_player + 1 ) % GlobalSnakeVar.g_numplayers
				var enemynext = GlobalSnakeVar.posdir2pos(GlobalSnakeVar.snakes[enemyindex].truecords[0], GlobalSnakeVar.snakes[enemyindex].truedir)
				newmap[GlobalSnakeVar.pos2index(enemynext)] = 1;
			counts.append(flood(newmap, testpos, 0))
			#if count2 < 30:
			#	value = 0
			if currentdir == x:
				if !(GlobalSnakeVar.foodpoly.truepos.x == truecords[0].x || GlobalSnakeVar.foodpoly.truepos.y == truecords[0].y):
					value = value * 1.2
			legalfoodrank.append(value)
	
	for x in legalmoves.size():
		if counts[x] < 10:
			legalfoodrank[x] = 0
		elif counts[x] < 20:
			legalfoodrank[x] = legalfoodrank[x]*.0001
		elif counts[x] < 40:
			legalfoodrank[x] = legalfoodrank[x]*.001
		elif counts[x] < 80:
			legalfoodrank[x] = legalfoodrank[x]*.1
	
	var bestrank = -1
	var bestans = GlobalSnakeVar.NODIR
	for x in legalmoves.size():
		if legalfoodrank[x]> bestrank:
			bestrank = legalfoodrank[x]
			bestans = legalmoves[x]
	if GlobalSnakeVar.g_rng.randi_range(0,100) > 99:
		if(legalmoves.size() != 0):
			reqdir = legalmoves[GlobalSnakeVar.g_rng.randi_range(0,legalmoves.size()-1)]
	else:
		reqdir = bestans;
	if GlobalSnakeVar.g_rng.randi_range(0,100) > 90:
		inputshoot = true
	else :
		inputshoot = false

func move_head():
	var goingto = GlobalSnakeVar.posdir2pos(truecords[0], truedir)
	if (GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(goingto)] == 1):
		emit_signal("snake_died", _player)
		return
		pass
	if (GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(goingto)] == 2):
		emit_signal("ate_food")
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
		tilerot[inverse] = tilerot[inverse - 1]
		GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[inverse])] = 1
		#tile_draw_snake_flag_from_true(i, inverse)

func shoot(pos, dir):
	#var bullet = Bullet.new()
	var bullet_packed = load("res://Assets/Bullet.tscn")
	var bullet = bullet_packed.instance()
	bullet.setup(pos, dir, _player)
	#if (GlobalSnakeVar.g_numplayers == 2):
		#bullet.connect("bullet_moved", GlobalSnakeVar.snakes[(_player + 1)%2], "check_bullet")
	get_parent().add_child(bullet)
	GlobalSnakeVar.bullets.append(bullet)
	canfire = false
	bulletcooldown.wait_time = GlobalSnakeVar.g_shoot_cooldown
	bulletcooldown.start()

func grow(tailpos, rot):
	var poly = Sprite.new()
	#poly.polygon = PoolVector2Array([
	#	Vector2(0,0),
	#	Vector2(0,GlobalSnakeVar.tilesize),
	#	Vector2(GlobalSnakeVar.tilesize,GlobalSnakeVar.tilesize),
	#	Vector2(GlobalSnakeVar.tilesize,0)
	#])
	#poly.centered = false
	poly.texture = bodytex
	#poly.scale.x = .5
	#poly.scale.y = .5

	#poly.position = Vector2(-100,-100)
	#poly.color = Color(0, 1, 0, 1)
	var colrect = CollisionShape2D.new()
	colrect.shape = CircleShape2D.new()
	#colrect.shape.set_extents(Vector2(GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2))
	colrect.shape.set_radius(1)
	colrect.position.x = tailpos.x + GlobalSnakeVar.tilesize/2
	colrect.position.y = tailpos.y + GlobalSnakeVar.tilesize/2
#	colrect.set_transform(Transform2D(
#		Vector2( GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2 ),
#		Vector2( GlobalSnakeVar.tilesize/2, GlobalSnakeVar.tilesize/2 ),
#		Vector2( 0, 0 )
#		))
	colshapes.append(colrect)
	sprites.append(poly)
	truecords.append(tailpos)

	tilerot.append(rot)
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(tailpos)] = 1
	#tile_draw_snake_flag_from_true(i, snakes[i]["snakelen"])
	add_child(poly)
	add_child(colrect)
	#colmap[pos2index(snakes[i]["truecords"][-1])] = 1
	#snakes[i]["snakelen"] += 1
	
func check_bullet(truepos, pastpos):	
	var xcleanup = []
	for x in truecords.size():
		#print("compar pos ", truepos, pastpos, " to ", truecords[x])
		#print("does pos ", pos, "match true cord[",x,"] = ", truecords[x])
		if (truecords[x] == pastpos || truecords[x] == truepos):
			#print("SIGNAL shot segment ", x)
			#got_shot(x)
			#emit_signal("snake_died", _player)
			xcleanup.append(x)
			break #retool
	if xcleanup.empty():
		breakpoint
	while (!xcleanup.empty()):
		var x = xcleanup[-1]
		got_shot(x)
		xcleanup.erase(x)
	pass

func got_shot(x):
	print(_player," was shot at", x)
	#if sprites.size() == 1:
	#	emit_signal("snake_died", _player)
	if x == 0:
		
		return
	#	x += 1
	GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[x])] = 0
	tilerot.erase(tilerot[x])
	remove_child(sprites[x])
	truecords.erase(truecords[x])
	remove_child(colshapes[x])
	colshapes.erase(colshapes[x])
	sprites.erase(sprites[x])
	snakecap -= 1
	
func flood(map, pos, depth):
	if map[GlobalSnakeVar.pos2index(pos)] == 1:
		return 0
	if depth == 25:
		return 1
	var ans = 0
	for i in 4:
		map[GlobalSnakeVar.pos2index(pos)] = 1
		var test1 = GlobalSnakeVar.posdir2pos(pos, i)
		if (map[GlobalSnakeVar.pos2index(test1)] != 1) && ans < 81:
			ans += flood(map, test1, depth + 1) + 1 
	return ans;
	
func tile_draw_snake_flag_from_true(segment):
	sprites[segment].position.x = truecords[segment].x + GlobalSnakeVar.tilesize/2
	sprites[segment].position.y = truecords[segment].y + GlobalSnakeVar.tilesize/2
	if (tilerot[segment] == GlobalSnakeVar.NORTH):
		sprites[segment].rotation = deg2rad(270)
	if (tilerot[segment] == GlobalSnakeVar.EAST):
		sprites[segment].rotation = 0
	if (tilerot[segment] == GlobalSnakeVar.SOUTH):
		sprites[segment].rotation = deg2rad(90)
	if (tilerot[segment] == GlobalSnakeVar.WEST):
		sprites[segment].rotation = deg2rad(180)

func ate_food_snake():
	GlobalSnakeVar.foodpoly.ate_food()
	snakecap += GlobalSnakeVar.g_foodsegments

func generic_area_handler(area_rid, area, area_shape_index, local_shape_index ):
	if (area.get_class() == "Bullet"):
		#print(_player, "ran into a bullet from ", area.parent_player)
		if (_player != area.parent_player):
			check_bullet(area.truepos,area.pastpos)
			area.remove_bullet()
			#print(area.truepos)
	if (area.get_class() == "Snake"):
		pass
		#print("ran into a snake ", area.name, " remote =",area_shape_index , " local = ", local_shape_index, " ", OS.get_ticks_usec())
		#emit_signal("snake_died", _player)
	#print(area.name, " cords" , area.position, " my pos", position)
	pass # Replace with function body.
	

func _on_Player_area_shape_entered (area_rid, area, area_shape_index, local_shape_index ):
	generic_area_handler(area_rid, area, area_shape_index, local_shape_index )

func _on_Enemy_area_shape_entered (area_rid, area, area_shape_index, local_shape_index ):
	generic_area_handler(area_rid, area, area_shape_index, local_shape_index )

func _on_Player_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("ran into a food? ", body.name, " ", OS.get_ticks_usec())
	pass # Replace with function body.
