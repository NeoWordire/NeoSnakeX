extends CanvasLayer


# Declare member variables here. Examples:
export (int) var width = 240
export (int) var height = 160
export (int) var moves_per_second = 5  #Times per second to move?
export (Texture) var playerbodytex
export (Texture) var playerheadtex
export (Texture) var enemybodytex
export (Texture) var enemyheadtex
export (int) var numplayers = 2
export (int) var tilesize = 8
var startpos = [
		Vector2(tilesize,floor(height/2/tilesize)*tilesize - tilesize), 
		Vector2(width - tilesize *2,floor(height/2/tilesize)*tilesize - tilesize)
	]
export (Texture) var foodtex
export (int) var FoodSegments = 5

enum {NORTH, EAST, SOUTH, WEST, NODIR}
const BIT1 = 1
const BIT2 = 1 << 1
const BIT3 = 1 << 2
const BIT4 = 1 << 3

# var a = 2
# var b = "text"

var rng = RandomNumberGenerator.new()
var time = 0

# snake items, each element is segment, head always 0, tail always snakelen-1
var newSnakeObj = {
	sprites = [],
	truecords = [], 
	tilerot = [], 
	snakelen = 0, 
	snakecap = 5,
	dir = NODIR,
	oldinputmask = 0
}

var snakes = []
var tempzero = []


#var playercolarea = []
#var snakes[0]["snakelen"] = 0
#var snakes[0]["snakecap"] = 5

var colmap = []
var gameover = false
var foodpoly = Polygon2D.new()

## Called when the node enters the scene tree for the first time.
func reset():
	rng.randomize()
	get_node("GameOver").visible = false
	for child in get_children():
		if child.name != "GameOver":
			child.queue_free()

	colmap = []
	for w in width/8:
		for h in height/8:
			colmap.append(0);
	tempzero = colmap.duplicate()
	snakes = []
	for x in numplayers:	
		var player = newSnakeObj.duplicate()
		snakes.append(player)
		snakes[x]["snakelen"] = 0
		snakes[x]["snakecap"] = 5

		snakes[x]["sprites"] = []
		snakes[x]["truecords"] = []
		snakes[x]["tilerot"] = []
		snakes[x]["dir"] = EAST
		snakes[x]["oldinputmask"] = 0
		grow(x, startpos[x], EAST)
		
	gameover = false
	foodpoly = Polygon2D.new()
	time = 0
	foodpoly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	
	snakes[0]["sprites"][0].set_texture(playerheadtex)
	if (numplayers == 2):
		snakes[1]["sprites"][0].set_texture(enemyheadtex)
	
	foodpoly.set_texture(foodtex)
	add_child(foodpoly)
	move_food()
	print(snakes)

func _ready():
	reset()

#call grow after moving but with old tail pos
func grow(i,tailpos,rot):
	var poly = Polygon2D.new()
	poly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	if (i == 0): ## ack
		poly.set_texture(playerbodytex)
	else:
		poly.set_texture(enemybodytex)
	snakes[i]["sprites"].append(poly)
	snakes[i]["truecords"].append(tailpos)
	snakes[i]["tilerot"].append(rot)
	#colmap[pos2index(tailpos)] = 1
	tile_update_from_true(i, snakes[i]["snakelen"])
	add_child(poly)
	snakes[i]["snakelen"] += 1
	
func pos2index(pos):
	return ((pos.y/tilesize)*(width/tilesize)) + (pos.x/tilesize)
	 
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
	remove_child(snakes[0]["sprites"][0])
	add_child(snakes[0]["sprites"][0])
	remove_child(node)
	add_child(node)
	node.visible = true

#call tile_update_from_true after
func move_head(i, newdir):
	snakes[i]["tilerot"][0] = newdir
	if (newdir == NORTH):
		snakes[i]["truecords"][0].y -= 1 * tilesize
	if (newdir == EAST):
		snakes[i]["truecords"][0].x += 1 * tilesize
	if (newdir == SOUTH):
		snakes[i]["truecords"][0].y += 1 * tilesize
	if (newdir == WEST):
		snakes[i]["truecords"][0].x -= 1 * tilesize

func tile_update_from_true(i,segment):
	if (snakes[i]["tilerot"][segment] == NORTH):
		snakes[i]["sprites"][segment].position.x = snakes[i]["truecords"][segment].x
		snakes[i]["sprites"][segment].position.y = snakes[i]["truecords"][segment].y + tilesize
		snakes[i]["sprites"][segment].rotation = deg2rad(270)
	if (snakes[i]["tilerot"][segment] == EAST):
		snakes[i]["sprites"][segment].position.x = snakes[i]["truecords"][segment].x
		snakes[i]["sprites"][segment].position.y = snakes[i]["truecords"][segment].y
		snakes[i]["sprites"][segment].rotation = deg2rad(0)
	if (snakes[i]["tilerot"][segment] == SOUTH):
		snakes[i]["sprites"][segment].position.x = snakes[i]["truecords"][segment].x + tilesize
		snakes[i]["sprites"][segment].position.y = snakes[i]["truecords"][segment].y
		snakes[i]["sprites"][segment].rotation = deg2rad(90)
	if (snakes[i]["tilerot"][segment] == WEST):
		snakes[i]["sprites"][segment].position.x = snakes[i]["truecords"][segment].x + tilesize
		snakes[i]["sprites"][segment].position.y = snakes[i]["truecords"][segment].y + tilesize
		snakes[i]["sprites"][segment].rotation = deg2rad(180)

func body_follow_head(i):
	if snakes[i]["snakelen"] <= 1:
		return
	for s in snakes[i]["snakelen"]-1:
		var inverse = snakes[i]["snakelen"] - s - 1
		snakes[i]["truecords"][inverse] = snakes[i]["truecords"][inverse-1] 
		snakes[i]["tilerot"][inverse] = snakes[i]["tilerot"][inverse - 1]
		tile_update_from_true(i, inverse)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#time += delta
	#if time < control_speed:
	#	return;

	#print("sleep ", (1000/control_speed)-delta*1000, " plus delta =", delta*1000)
	#time += delta
	#if time < 1.0/moves_per_second:
#		return;
	if gameover:
		return
	
	time = 0
	get_input(0);
	
	# HACK, REPLACE with clean update code, rough hack to make colmap accurate
	colmap = tempzero.duplicate()
	for x in numplayers:
		for s in snakes[x]["truecords"].size():
			colmap[pos2index(snakes[x]["truecords"][s])] = 1
	colmap[pos2index(foodpoly.position)] = 2
	
	for x in numplayers:
		snakes[x]["tilerot"][0] = snakes[x]["dir"]  #rotate old head to current dir
		var oldtailcord = snakes[x]["truecords"][snakes[x]["snakelen"]-1]
		var oldsnakesrot = snakes[x]["tilerot"][snakes[x]["snakelen"]-1]

		#Follow Head
		body_follow_head(x)
		#Move Head,
		if x == 1:
			snakes[1]["dir"] = (snakes[0]["dir"]+2) %4
			
		move_head(x, snakes[x]["dir"] )
#	move_head(1, snakes[1]["dir"] )
		tile_update_from_true(x, 0)
		if (snakes[x]["snakelen"]< snakes[x]["snakecap"]):
			grow(x, oldtailcord, oldsnakesrot)
			pass
		if (snakes[x]["truecords"][0].x < 0 ||  snakes[x]["truecords"][0].x > width - tilesize ||
				snakes[x]["truecords"][0].y < 0 || snakes[x]["truecords"][0].y > height - tilesize):
			print("WALLDED")
			game_over()
			return
		elif colmap[pos2index(snakes[x]["truecords"][0])] == 1:
			print("DED")
			print("POSINDEX", pos2index(snakes[x]["truecords"][0]))
			game_over()
			return
		elif colmap[pos2index(snakes[x]["truecords"][0])] == 2:
			print("FOOD")
			move_food()
			snakes[x]["snakecap"] += FoodSegments
	OS.delay_msec((1000/moves_per_second)-delta*1000)
	
func get_input(i):
	# velocity = Vector2()
	var inputmask = 0
	var oldinputmask = snakes[i]["oldinputmask"] 
	if Input.is_action_pressed("ui_right"):
		inputmask |= BIT1
	if Input.is_action_pressed("ui_left"):
		inputmask |= BIT2
	if Input.is_action_pressed("ui_down"):
		inputmask |= BIT3
	if Input.is_action_pressed("ui_up"):
		inputmask |= BIT4
	if inputmask != oldinputmask:
		if (inputmask & (~oldinputmask)) == BIT1 && snakes[i]["dir"]  != WEST:
			snakes[i]["dir"]  = EAST
		elif (inputmask & (~oldinputmask)) == BIT2 && snakes[i]["dir"]  != EAST:
			snakes[i]["dir"]  = WEST
		elif (inputmask & (~oldinputmask)) == BIT3 && snakes[i]["dir"]  != NORTH:
			snakes[i]["dir"]  = SOUTH
		elif (inputmask & (~oldinputmask)) == BIT4 && snakes[i]["dir"]  != SOUTH:
			snakes[i]["dir"]  = NORTH
		else : #released a key, fall back to priority...
			if Input.is_action_pressed("ui_right") &&  snakes[i]["dir"]  != WEST:
				snakes[i]["dir"]  = EAST
			if Input.is_action_pressed("ui_left") &&  snakes[i]["dir"]  != EAST:
				snakes[i]["dir"]  = WEST
			if Input.is_action_pressed("ui_up") &&  snakes[i]["dir"]  != SOUTH:
				snakes[i]["dir"]  = NORTH
			if Input.is_action_pressed("ui_down") &&  snakes[i]["dir"]  != NORTH:
				snakes[i]["dir"]  = SOUTH
	snakes[i]["oldinputmask"] = inputmask

func _on_GameOver_pressed():
	reset()
	pass # Replace with function body.
