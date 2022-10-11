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
export (int) var borderintiles = 1 
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
		if x == 0:
			grow(x, startpos[x], EAST)
		else:
			grow(x, startpos[x], WEST)
			snakes[x]["dir"]  = WEST
		
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
	
func posdir2pos(pos, newdir):
	if (newdir == NORTH):
		pos.y -= 1 * tilesize
	if (newdir == EAST):
		pos.x += 1 * tilesize
	if (newdir == SOUTH):
		pos.y += 1 * tilesize
	if (newdir == WEST):
		pos.x -= 1 * tilesize
	return pos

func pos2index(pos):
	return ((pos.y/tilesize)*(width/tilesize)) + (pos.x/tilesize)
	 
func move_food():
	foodpoly.position.x = rng.randi_range(borderintiles * tilesize,width/tilesize - borderintiles * tilesize)*tilesize
	foodpoly.position.y = rng.randi_range(borderintiles * tilesize,height/tilesize- borderintiles *tilesize)*tilesize
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
		#tile_update_from_true(i, inverse)
		

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
		if x == 1:
			#snakes[1]["dir"] = (snakes[0]["dir"]+2) %4
			ai_get_input(x)
			
		#snakes[x]["tilerot"][0] = snakes[x]["dir"]  #rotate old head to current dir
		var oldtailcord = snakes[x]["truecords"][snakes[x]["snakelen"]-1]
		var oldsnakesrot = snakes[x]["tilerot"][snakes[x]["snakelen"]-1]
		
		#Follow Head

		body_follow_head(x)
		#Move Head,
		move_head(x, snakes[x]["dir"] )
		
		if (snakes[x]["snakelen"]< snakes[x]["snakecap"]):
			grow(x, oldtailcord, oldsnakesrot)
			pass
		if (snakes[x]["truecords"][0].x < borderintiles * tilesize ||  snakes[x]["truecords"][0].x > width - (borderintiles+1) * tilesize ||
				snakes[x]["truecords"][0].y < borderintiles * tilesize || snakes[x]["truecords"][0].y > height - (borderintiles+1) * tilesize):
			print("WALLDED")
			game_over()
			return
		elif colmap[pos2index(snakes[x]["truecords"][0])] == 1:
			print("DED")
			game_over()
			return
		elif colmap[pos2index(snakes[x]["truecords"][0])] == 2:
			print("FOOD")
			move_food()
			snakes[x]["snakecap"] += FoodSegments
	for x in numplayers:
		for s in snakes[x]["truecords"].size():
			tile_update_from_true(x, s)
	if ((1000/moves_per_second)-delta*1000 > 0):
		OS.delay_msec((1000/moves_per_second)-delta*1000)
	else:
		print("lagged:", (1000/moves_per_second)-delta*1000)

func flood(map, pos, depth):
	if (depth > 25):
		return 1
	var ans = 0
	for i in 4:
		var test1 = posdir2pos(pos, i)
		if (test1.x > (borderintiles - 1)*tilesize &&
			test1.y > (borderintiles - 1) *tilesize &&
			test1.x < width - borderintiles*tilesize &&
			test1.y < height - borderintiles*tilesize &&
			map[pos2index(test1)] == 0):
				map[pos2index(test1)] = 1
				ans += flood(map, test1, depth + 1) + 1
	return ans;


func ai_get_input(i):
	var currentdir = snakes[i]["dir"]
	var goalpos = foodpoly.position
	if (goalpos.x > snakes[i]["truecords"][0].x):
		if (currentdir == WEST):
			snakes[i]["dir"] = SOUTH
		else:
			snakes[i]["dir"] = EAST
	if (goalpos.x < snakes[i]["truecords"][0].x):
		if (currentdir == EAST):
			snakes[i]["dir"] = SOUTH
		else:
			snakes[i]["dir"] = WEST
	if (goalpos.y > snakes[i]["truecords"][0].y):
		if (currentdir == NORTH):
			snakes[i]["dir"] = WEST
		else:
			snakes[i]["dir"] = SOUTH
	if (goalpos.y < snakes[i]["truecords"][0].y):
		if (currentdir == SOUTH):
			snakes[i]["dir"] = WEST
		else:
			snakes[i]["dir"] = NORTH
	var maxcnt = 0
	var maxdir
	for x in 4:
		var test = posdir2pos(snakes[i]["truecords"][0], snakes[i]["dir"])
		if (colmap[pos2index(test)] != 1 &&
				test.x > (borderintiles - 1)*tilesize &&
				test.y > (borderintiles - 1) *tilesize &&
				test.x < width - borderintiles*tilesize &&
				test.y < height - borderintiles*tilesize
				):
			var aiflood = colmap.duplicate()
			var safe = false
			var count = flood(aiflood,test, 0)
	
			#print ("count ", count)
			if count >30:
				break
		snakes[i]["dir"] = (snakes[i]["dir"] + 1) % 4


	
	
		

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
