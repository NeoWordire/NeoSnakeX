extends Area2D
class_name Snake2, "res://Assets/Textures/snake_head.png"
func get_class(): return "Snake"
#const Bullet = preload("res://Scripts/Bullet.gd")
var bullet_packed = load("res://BattleScene/SubSceneObjects/Bullet.tscn")
var SnakeBodyDeadParticle = load("res://BattleScene/SubSceneObjects/SnakeBodyDeadParticle.tscn")
var SnakeBodyMainSprite = load("res://BattleScene/SubSceneObjects/SnakeBodyParticle.tscn")

signal snake_died(player)
signal ate_food()

#class_name Bullet
var sprites = []
#var splitMap = []
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
var futureheadpos : Vector2
var _player

var canfire = true;


func update_ray():
	get_node("ray").position = sprites[0].position
	var castscalar = GlobalSnakeVar.posdir2pos(Vector2(0,0), reqdir)
	castscalar *= max(GlobalSnakeVar.width,GlobalSnakeVar.height)/GlobalSnakeVar.tilesize
	get_node("ray").cast_to = castscalar

func setup(player):
	_player = player
	for sprite in sprites:
		remove_child(sprite)
		sprite.queue_free()

	sprites = [];
#	splitMap = []
	snakecap = 5
	#get_node("shootCoolDown").connect("timeout",self,"fire_cooled_off")
	#get_node("shootCoolDown").one_shot = true
	
	#build head specially
	var poly = SnakeBodyMainSprite.instance()
	
	poly.texture = headtex
	poly.position = startpos
	poly.truedir = truedir
	
#	splitMap.append(0)
	
	reqdir = startRotation
	truedir = startRotation
	sprites.append(poly)
	add_child(poly)
	update_ray()
	for i in snakecap:
		pass
		#play_movement()
	#return 

func _ready():
	position = Vector2(0,0)
	if (self.connect("ate_food", self, "ate_food_snake") != OK):
		breakpoint # debugging only remove for release XXX
	pass

var lastrun = 0



#func step_simulation():
func decide_turn():
	var time = OS.get_ticks_usec()
	GlobalSnakeVar.g_time_between_snake = time - lastrun
	lastrun = time
	if(HumanOrCPU == 0):
		get_input()
	else :
		get_input_ai()
	#play_movement()
	pass
	
func play_movement():
	var died = false
	var oldtailforgrow = sprites[-1].position
	var oldtailsrot = sprites[-1].truedir
	var oldheadpos = sprites[0].position
	var oldheadrot = sprites[0].truedir
		#grow
	truedir = reqdir
	if (!move_head()):
		died = true
		return died
		#print("DIED")
	if inputshoot && canfire:
		shoot(sprites[0].position,truedir)
	if snakecap > sprites.size():
		grow(oldtailforgrow, oldtailsrot)
	body_follow_head(oldheadpos, oldheadrot)

	if (sprites.size() > 1):
		sprites[1].truedir =truedir  #rotate old head to current dir
	return died

func _process(_delta):
#	if (HumanOrCPU==0):
		#get_input()
	pass

func _physics_process(_delta):
	#no op since driven by MainSnake _physics_process?
	pass

var lerptime = 0
var updatetime = 999
func update_display():
	for s in sprites.size():
		tile_draw_snake_flag_from_true(s)

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
	inputshoot = false
	if Input.is_key_pressed(KEY_CONTROL) ||  Input.is_action_pressed("ui_accept"):
		inputshoot = true

func get_input_ai():
	var currentdir = truedir
	var goalpos = GlobalSnakeVar.foodpoly.position
	var legalmoves = []
	var legalfoodrank = []
	var counts = []
	for x in 4:
		
		get_node("ray").position = sprites[0].position
		var castscalar = GlobalSnakeVar.posdir2pos(Vector2(0,0), x)
		castscalar *= max(GlobalSnakeVar.width,GlobalSnakeVar.height)/GlobalSnakeVar.tilesize
		get_node("ray").cast_to = castscalar

		get_node("ray").enabled = true
		if (get_node("ray").is_colliding()):
			print(get_node("ray").get_collider_shape)
			break
#		var testpos = GlobalSnakeVar.posdir2pos(sprites[0].position, x)
#		#if GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(testpos)] != 1:
#		if (truedir + 2 % 4) == x:
#			continue
#		if GlobalSnakeVar.g_boardSprites.has(testpos):
#			continue
#		if (testpos.x < 0 ||
#				testpos.y < 0):
#			continue
#		if (testpos.x > GlobalSnakeVar.width - GlobalSnakeVar.borderintiles * 1 * GlobalSnakeVar.tilesize ||
#				testpos.y > GlobalSnakeVar.height - GlobalSnakeVar.borderintiles * 1 * GlobalSnakeVar.tilesize):
#			continue
#		if GlobalSnakeVar.g_numplayers == 2:
#			var enemyindex = (_player + 1 ) % GlobalSnakeVar.g_numplayers
#			var safe = true
#			#for dir in 4:
#			var enemynext = GlobalSnakeVar.posdir2pos(GlobalSnakeVar.snakes[enemyindex].sprites[0].position, GlobalSnakeVar.snakes[enemyindex].sprites[0].truedir)
#			if enemynext == testpos:
#					safe = false
#			if !safe:
#				continue
		legalmoves.append(x) 
		#var value = (Vector2(0,0).distance_to(Vector2(GlobalSnakeVar.width,GlobalSnakeVar.height)) - testpos.distance_to(goalpos))/2
#		var newmap = GlobalSnakeVar.colmap.duplicate()
#		if GlobalSnakeVar.g_numplayers == 2:
#			var enemyindex = (_player + 1 ) % GlobalSnakeVar.g_numplayers
#			var enemynext = GlobalSnakeVar.posdir2pos(GlobalSnakeVar.snakes[enemyindex].truecords[0], GlobalSnakeVar.snakes[enemyindex].truedir)
#			newmap[GlobalSnakeVar.pos2index(enemynext)] = 1;
#		counts.append(flood(newmap, testpos, 0))
		counts.append(100)
		#if count2 < 30:
		#	value = 0
#		if currentdir == x:
#			if !(GlobalSnakeVar.foodpoly.position.x == sprites[0].position.x ||
#					GlobalSnakeVar.foodpoly.position.y == sprites[0].position.y):
#				value = value * 1.2
	#legalfoodrank.append(value)
	
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
	inputshoot = false
	print("player ", _player, " move ", reqdir, " choices ", legalmoves)

func move_head():
	var goingto = GlobalSnakeVar.posdir2pos(sprites[0].position, truedir)
	if (GlobalSnakeVar.g_boardSprites.has(goingto) ||
			goingto.x < 0 || 
			goingto.y < 0 ||
			goingto.x > GlobalSnakeVar.width - GlobalSnakeVar.borderintiles * -2 *GlobalSnakeVar.tilesize ||
			goingto.y > GlobalSnakeVar.height - GlobalSnakeVar.borderintiles * -2 * GlobalSnakeVar.tilesize):
#		print(goingtopre
#		print("x = ", GlobalSnakeVar.width - GlobalSnakeVar.borderintiles * GlobalSnakeVar.tilesize * 2)
#		print("y = ", GlobalSnakeVar.width - GlobalSnakeVar.borderintiles * GlobalSnakeVar.tilesize * 2)
		#XXXemit_signal("snake_died", _player)
		#XXXreturn
		pass
	if (goingto == GlobalSnakeVar.foodpoly.position):
		emit_signal("ate_food")
	GlobalSnakeVar.g_boardSprites.erase(sprites[0].position)
	sprites[0].position = goingto
	sprites[0].truedir = truedir
	GlobalSnakeVar.g_boardSprites[sprites[0].position] = sprites[0]
	return true

func body_follow_head(prevheadpos,prevrot):
	if sprites.size() <= 1:
		GlobalSnakeVar.g_boardSprites.erase(sprites[0].position)
		return
	GlobalSnakeVar.g_boardSprites.erase(sprites[-1].position)
	
	var followcord = prevheadpos
	var followRot = prevrot
	for s in range(1, sprites.size()):
		GlobalSnakeVar.g_boardSprites.erase(sprites[s].position)
		sprites[s].texture = bodytex
		var tempCord = followcord
		var tempRot = followRot
		followcord = sprites[s].position
		followRot = sprites[s].truedir
		sprites[s].position = tempCord
		sprites[s].truedir = tempRot
		GlobalSnakeVar.g_boardSprites[sprites[s].position] = sprites[s]

func shoot(pos, dir):
	var bullet = bullet_packed.instance()
	bullet.setup(pos, dir, _player)
	add_child(bullet)
	GlobalSnakeVar.bullets.append(bullet)
	canfire = false
	get_node("shootCoolDown").wait_time = GlobalSnakeVar.g_shoot_cooldown
	get_node("shootCoolDown").start()
	SoundPlayer.play_sound(SoundPlayer.SFXSHOOT)

func grow(tailpos, rot):
	var spriteinstance = SnakeBodyMainSprite.instance()
	spriteinstance.texture = bodytex

	GlobalSnakeVar.g_boardSprites[tailpos] = spriteinstance
	spriteinstance.position = tailpos
	spriteinstance.truedir = rot
	sprites.append(spriteinstance)

#	splitMap.append(splitMap[-1])

	#GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(tailpos)] = 1
	#tile_draw_snake_flag_from_true(i, snakes[i]["snakelen"])
	add_child(spriteinstance)
	#colmap[pos2index(snakes[i]["truecords"][-1])] = 1
	#snakes[i]["snakelen"] += 1
	
func check_bullet(truepos, pastpos):	
	for x in sprites.size():
		if (sprites[x].position == truepos || sprites[x].position == pastpos):
			got_shot(x)
			return #retool
	#debug XXX remove before ship
	breakpoint

func got_shot(x):
	#if sprites.size() == 1:
	#	emit_signal("snake_died", _player)
	if x == 0:
		print(_player," was shot in head do nothing")
		SoundPlayer.play_sound(SoundPlayer.SFXHURT)
		return
	if sprites.size() <= 2:
		print("Too small to be shot")
		SoundPlayer.play_sound(SoundPlayer.SFXHURT)
		return
	#	x += 
	SoundPlayer.play_sound(SoundPlayer.SFXHURT2)
	print(_player," was shot at segment ", x)
	#GlobalSnakeVar.colmap[GlobalSnakeVar.pos2index(truecords[sprites.size()-1])] = 0
	GlobalSnakeVar.g_boardSprites.erase(sprites[-1].position)
	#for t in range(x, splitMap.size()):
	#	splitMap[t] += 1
	var temp = SnakeBodyDeadParticle.instance()
	temp.position = sprites[x].position
	temp.rotation = sprites[x].rotation
	temp.texture = bodytex
	add_child(temp)
	#sprites[x].texture = bodywarptex
	#sprites[x].texture.pause = true
#	splitMap.remove(sprites.size()-1)
	remove_child(sprites[sprites.size()-1])
	sprites.remove(sprites.size()-1)
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
#	sprites[segment].position.x = truecords[segment].x + GlobalSnakeVar.tilesize/2
#	sprites[segment].position.y = truecords[segment].y + GlobalSnakeVar.tilesize/2
	if (sprites[segment].truedir == GlobalSnakeVar.NORTH):
		sprites[segment].rotation = deg2rad(270)
	if (sprites[segment].truedir == GlobalSnakeVar.EAST):
		sprites[segment].rotation = 0
	if (sprites[segment].truedir == GlobalSnakeVar.SOUTH):
		sprites[segment].rotation = deg2rad(90)
	if (sprites[segment].truedir == GlobalSnakeVar.WEST):
		sprites[segment].rotation = deg2rad(180)

func ate_food_snake():
	GlobalSnakeVar.foodpoly.ate_food()
	snakecap += GlobalSnakeVar.g_foodsegments

func generic_area_handler(_area_rid, area, _area_shape_index, _local_shape_index ):
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

func _on_Player_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	print("ran into a food? ", body.name, " ", OS.get_ticks_usec())
	pass # Replace with function body.

func _on_shootCoolDown_timeout():
	canfire = true;
