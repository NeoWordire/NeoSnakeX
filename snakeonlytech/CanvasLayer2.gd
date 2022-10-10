extends CanvasLayer


# Declare member variables here. Examples:
export (int) var width = 240
export (int) var height = 160
export (int) var moves_per_second = 5  #Times per second to move?
export (Texture) var playerbodytex
export (Texture) var playerheadtex
export (int) var tilesize = 8
var playerstartpos = Vector2(tilesize,floor(height/2/tilesize)*tilesize - tilesize)
export (Texture) var foodtex
export (int) var FoodSegments = 5

enum {NORTH, EAST, SOUTH, WEST, NODIR}
const BIT1 = 1
const BIT2 = 1 << 1
const BIT3 = 1 << 2
const BIT4 = 1 << 3

# var a = 2
# var b = "text"
var dir = NODIR
var rng = RandomNumberGenerator.new()
var time = 0

# snake head always 0, tail always -1
var playersprites = []
var playertruecords = []
var playertilerot = []

#var playercolarea = []
var snakelen = 0
var snakecap = 5

var colmap = []
var gameover = false
var foodpoly = Polygon2D.new()
var inputmask = 0;
var oldinputmask = 0;
var tempzero = []

## Called when the node enters the scene tree for the first time.
func reset():
	rng.randomize()
	get_node("GameOver").visible = false
	for child in get_children():
		if child.name != "GameOver":
			child.queue_free()
	playersprites = []
	playertruecords = []
	playertilerot = []
#var playercolarea = []
	colmap = []
	for w in width:
		for h in height:
			colmap.append(0);
	tempzero = colmap.duplicate()
	snakelen = 0
	snakecap = 5
	gameover = false
	foodpoly = Polygon2D.new()
	dir = EAST
	oldinputmask = 0
	time = 0
	foodpoly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	grow(playerstartpos, EAST)
	playersprites[0].set_texture(playerheadtex)
	foodpoly.set_texture(foodtex)
	add_child(foodpoly)
	move_food()

func _ready():
	reset()

#call grow after moving but with old tail pos
func grow(tailpos,rot):
	var poly = Polygon2D.new()
	poly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	poly.set_texture(playerbodytex)
#	if playersnake.size() == 0 :
	#poly.position = tailpos
	if (rot == NORTH):
		poly.position.x = tailpos.x
		poly.position.y = tailpos.y + tilesize
		poly.rotation = deg2rad(270)
	if (rot == EAST):
		poly.rotation = deg2rad(0)
		poly.position.x = tailpos.x
		poly.position.y = tailpos.y
	if (rot == SOUTH):
		poly.position.x = tailpos.x + tilesize
		poly.position.y = tailpos.y
		poly.rotation = deg2rad(90)
	if rot == WEST:
		poly.rotation = deg2rad(180)
		poly.position.x = tailpos.x + tilesize
		poly.position.y = tailpos.y + tilesize
	
	playersprites.append(poly)
	playertruecords.append(tailpos)
	playertilerot.append(rot)
	colmap[pos2index(tailpos)] = 1
	add_child(poly)
	snakelen += 1
	
func pos2index(pos):
	return pos.y*height/tilesize + pos.x
	 
	
func move_food():
	foodpoly.position.x = rng.randi_range(0,width/tilesize - tilesize)*tilesize
	foodpoly.position.y = rng.randi_range(0,height/tilesize- tilesize)*tilesize
	if colmap[pos2index(foodpoly.position)] != 0:
		move_food();
#
func game_over():
	print("GAMEOVER")
	gameover = true
	var node = get_node("GameOver")
	remove_child(node)
	add_child(node)
	remove_child(playersprites[0])
	add_child(playersprites[0])
	node.visible = true

func move_head(newdir):
	playertilerot[0] = newdir
	if (newdir == NORTH):
		playertruecords[0].y -= 1 * tilesize
	if (newdir == EAST):
		playertruecords[0].x += 1 * tilesize
	if (newdir == SOUTH):
		playertruecords[0].y += 1 * tilesize
	if (newdir == WEST):
		playertruecords[0].x -= 1 * tilesize

func tile_update_from_true(index):
	if (playertilerot[index] == NORTH):
		playersprites[index].position.x = playertruecords[index].x
		playersprites[index].position.y = playertruecords[index].y + tilesize
		playersprites[index].rotation = deg2rad(270)
	if (playertilerot[index] == EAST):
		playersprites[index].position.x = playertruecords[index].x
		playersprites[index].position.y = playertruecords[index].y
		playersprites[index].rotation = deg2rad(0)
	if (playertilerot[index] == SOUTH):
		playersprites[index].position.x = playertruecords[index].x + tilesize
		playersprites[index].position.y = playertruecords[index].y
		playersprites[index].rotation = deg2rad(90)
	if (playertilerot[index] == WEST):
		playersprites[index].position.x = playertruecords[index].x + tilesize
		playersprites[index].position.y = playertruecords[index].y + tilesize
		playersprites[index].rotation = deg2rad(180)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#time += delta
	#if time < control_speed:
	#	return;
	#print(delta*100000)

	#print("sleep ", (1000/control_speed)-delta*1000, " plus delta =", delta*1000)
	#time += delta
	#if time < 1.0/moves_per_second:
#		return;
	if gameover:
		return
	#print(delta*100000)
	
	time = 0
	get_input();
	playertilerot[0] = dir #rotate old head to current dir
	
	# HACK, REPLACE with clean update code, rough hack to make colmap accurate
	colmap = tempzero.duplicate()
	for i in playertruecords.size():
		colmap[pos2index(playertruecords[i])] = 1
	colmap[pos2index(foodpoly.position)] = 2
	
	var oldtailcord = playertruecords[-1]
	var oldplayertilerot = playertilerot[-1]
	
	#Follow Head
	var temp
	if (snakelen > 1):
		temp = oldplayertilerot
		
	for i in snakelen-1:
		var inverse = snakelen - i - 1
		playertruecords[inverse] = playertruecords[inverse-1] 
		playertilerot[inverse] = playertilerot[inverse - 1]
		tile_update_from_true(inverse)
		temp = playertilerot[inverse-1]
		
	#Move Head,
	move_head(dir)
	if (snakelen< snakecap):
		grow(oldtailcord, oldplayertilerot)
	if (playertruecords[0].x < 0 ||  playertruecords[0].x > width - tilesize ||
			playertruecords[0].y < 0 || playertruecords[0].y > height - tilesize):
		print("WALLDED")
		game_over()
		return
	elif colmap[pos2index(playertruecords[0])] == 1:
		print("DED")
		game_over()
		return
	elif colmap[pos2index(playertruecords[0])] == 2:
		print("FOOD")
		move_food()
		snakecap += FoodSegments
	tile_update_from_true(0)
	OS.delay_msec((1000/moves_per_second)-delta*1000)
	
func get_input():
	# velocity = Vector2()
	inputmask = 0;
	if Input.is_action_pressed("ui_right"):
		inputmask |= BIT1
	if Input.is_action_pressed("ui_left"):
		inputmask |= BIT2
	if Input.is_action_pressed("ui_down"):
		inputmask |= BIT3
	if Input.is_action_pressed("ui_up"):
		inputmask |= BIT4
	if inputmask != oldinputmask:
		if (inputmask & (~oldinputmask)) == BIT1 && dir != WEST:
			dir = EAST
		elif (inputmask & (~oldinputmask)) == BIT2 && dir != EAST:
			dir = WEST
		elif (inputmask & (~oldinputmask)) == BIT3 && dir != NORTH:
			dir = SOUTH
		elif (inputmask & (~oldinputmask)) == BIT4 && dir != SOUTH:
			dir = NORTH
		else : #released a key, fall back to priority...
			if Input.is_action_pressed("ui_right") &&  dir != WEST:
				dir = EAST
			if Input.is_action_pressed("ui_left") &&  dir != EAST:
				dir = WEST
			if Input.is_action_pressed("ui_up") &&  dir != SOUTH:
				dir = NORTH
			if Input.is_action_pressed("ui_down") &&  dir != NORTH:
				dir = SOUTH
	oldinputmask = inputmask

func _on_GameOver_pressed():
	reset()
	pass # Replace with function body.
