extends CanvasLayer


# Declare member variables here. Examples:
var width = 240
var height = 160
export (int) var moves_per_second = 5  #Times per second to move?
export (Texture) var playerbodytex
export (Texture) var playerheadtex
export (Texture) var enemybodytex
export (Texture) var enemyheadtex
export (int) var numplayers = 2
var tilesize = 8
var borderintiles = 1 
export (int, "player","ai") var player1Ctrl
var startpos = [
		Vector2(tilesize,floor(height/2/tilesize)*tilesize - tilesize), 
		Vector2(width - tilesize *2,floor(height/2/tilesize)*tilesize - tilesize)
	]
export (Texture) var foodtex
export (int) var FoodSegments = 5
export (int) var CountDownStart = 3

enum {NORTH, EAST, SOUTH, WEST, NODIR}
const NORTHBIT = 1
const EASTBIT = 1 << 1
const SOUTHBIT = 1 << 2
const WESTBIT = 1 << 3

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
	truedir = NODIR,
	reqdir = NODIR,
	inputqueue = []
}

	
var paused = true
var cntpaused = true
var snakes = []
var emptyboard = []


#var playercolarea = []
#var snakes[0]["snakelen"] = 0
#var snakes[0]["snakecap"] = 5
var countdown = CountDownStart
var colmap = []
var gameover = false
var foodpoly = Polygon2D.new()


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

func game_over():
	print("GAMEOVER")
	gameover = true
	var node = get_node("GameOver")
	remove_child(snakes[0]["sprites"][0]) # hack to put head on top
	add_child(snakes[0]["sprites"][0])
	remove_child(node)
	add_child(node)
	node.visible = true


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
	colmap[pos2index(foodpoly.position)] = 2

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
		

func flood(map, pos, depth):
	if map[pos2index(pos)] == 1:
		return 0
	var ans = 0
	for i in 4:
		map[pos2index(pos)] = 1
		var test1 = posdir2pos(pos, i)
		if (map[pos2index(test1)] != 1):
			ans += flood(map, test1, depth + 1) + 1 
	return ans;

func get_input(x):
	# velocity = Vector2()
	var oldinputmask = 0;
	# iterate over inputqueue and collect all bits 
	for i in snakes[x]["inputqueue"].size():
		oldinputmask |= 1 << snakes[x]["inputqueue"][i]
	
	if Input.is_action_pressed("ui_right"):
		if oldinputmask & EASTBIT == 0:
			snakes[x]["inputqueue"].append(EAST)
	else:
		snakes[x]["inputqueue"].erase(EAST)
	if Input.is_action_pressed("ui_left"):
		if oldinputmask & WESTBIT == 0:
			snakes[x]["inputqueue"].append(WEST)
	else:
		snakes[x]["inputqueue"].erase(WEST)
	if Input.is_action_pressed("ui_up"):
		if oldinputmask & NORTHBIT == 0:
			snakes[x]["inputqueue"].append(NORTH)
	else:
		snakes[x]["inputqueue"].erase(NORTH)
	if Input.is_action_pressed("ui_down"):
		if oldinputmask & SOUTHBIT == 0:
			snakes[x]["inputqueue"].append(SOUTH)
	else:
		snakes[x]["inputqueue"].erase(SOUTH)
	if (snakes[x]["inputqueue"].size()!= 0):
		if ((snakes[x]["truedir"] + 2)%4 != snakes[x]["inputqueue"][-1]):
			snakes[x]["reqdir"] = snakes[x]["inputqueue"][-1]

func ai_get_input(i):
	var currentdir = snakes[i]["truedir"]
	var goalpos = foodpoly.position
	var legalmoves = []
	var legalfoodrank = []
	var legalfloodrank = []
	var counts = []
	for x in 4:
		var testpos = posdir2pos(snakes[i]["truecords"][0], x)
		if colmap[pos2index(testpos)] != 1:
			legalmoves.append(x)
			#legalrank.append(150-abs(testpos.distance_to(Vector2(width/2,height/2))))
			#Vector2(0,0)
			#legalfoodrank.append(Vector2(0,0).distance_to(Vector2(width,height))
	#				- (testpos.distance_to(foodpoly.position)))
			var value = (Vector2(0,0).distance_to(Vector2(width,height)) - testpos.distance_to(foodpoly.position))/2
			var newmap = colmap.duplicate()
			counts.append(flood(newmap, testpos, 0))
			#if count2 < 30:
			#	value = 0
			if currentdir == x:
				if !(foodpoly.position.x == snakes[i]["truecords"][0].x || foodpoly.position.y == snakes[i]["truecords"][0].y):
					value = value * 1.2
			legalfoodrank.append(value)
	
	for x in legalmoves.size():
		if counts[x] < 10:
			legalfoodrank[x] = 0
		if counts[x] < 20:
			legalfoodrank[x] = legalfoodrank[x]*.0001
		if counts[x] < 40:
			legalfoodrank[x] = legalfoodrank[x]*.001
		if counts[x] < 80:
			legalfoodrank[x] = legalfoodrank[x]*.1
	
	var bestrank = -1
	var bestans = NODIR
	for x in legalmoves.size():
		if legalfoodrank[x]> bestrank:
			bestrank = legalfoodrank[x]
			bestans = legalmoves[x]
	if rng.randi_range(0,100) > 99:
		snakes[i]["reqdir"] = legalmoves[rng.randi_range(0,legalmoves.size()-1)]
	else:
		snakes[i]["reqdir"] = bestans;

## Called when the node enters the scene tree for the first time.
func reset():
	rng.randomize()
	get_node("GameOver").visible = false
	for snake in snakes:
		for x in snake["snakelen"]:
			snake["sprites"][x].queue_free()
	foodpoly.queue_free()
	countdown = CountDownStart
	paused = false
	cntpaused = true
	get_node("StartCount").visible = true
	get_node("StartCount").text = str(countdown)
	colmap = []
	for h in height/8.0:
		for w in width/8.0:
			if h == height/8-1 || h ==0:
				colmap.append(1);
			elif w == width/8-1 || w ==0:
				colmap.append(1);
			else :
				colmap.append(0);
	emptyboard = colmap.duplicate()
	snakes = []
	for x in numplayers:	
		var player = newSnakeObj.duplicate()
		snakes.append(player)
		snakes[x]["snakelen"] = 0
		snakes[x]["snakecap"] = 5

		snakes[x]["sprites"] = []
		snakes[x]["truecords"] = []
		snakes[x]["tilerot"] = []
		snakes[x]["truedir"] = EAST
		snakes[x]["oldinputmask"] = []
		if x == 0:
			snakes[x]["truedir"]  = EAST
			snakes[x]["reqdir"]  = EAST
		else:
			snakes[x]["truedir"]  = WEST
			snakes[x]["reqdir"]  = WEST
		
		grow(x, startpos[x], snakes[x]["truedir"])
		body_follow_head(x)
		move_head(x, snakes[x]["truedir"])
		tile_update_from_true(x, 0)
		grow(x, startpos[x], snakes[x]["truedir"])
		tile_update_from_true(x, 0)
		body_follow_head(x)
		move_head(x, snakes[x]["truedir"])
		grow(x, startpos[x], snakes[x]["truedir"])
		tile_update_from_true(x, 0)
		body_follow_head(x)
		move_head(x, snakes[x]["truedir"])
		grow(x, startpos[x], snakes[x]["truedir"])
		tile_update_from_true(x, 0)
		body_follow_head(x)
		move_head(x, snakes[x]["truedir"])
		grow(x, startpos[x], snakes[x]["truedir"])
		tile_update_from_true(x, 4)
		tile_update_from_true(x, 3)
		tile_update_from_true(x, 2)
		tile_update_from_true(x, 1)
		tile_update_from_true(x, 0)
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

func _physics_process(delta):
	time += delta
	if (cntpaused):
		if(countdown <= 0):
				get_node("StartCount").visible = false
				cntpaused = false
				return
		get_node("StartCount").raise()		
		if (time > 1.0):
			time -= 1.0
			countdown -= 1
			if (countdown > 0):
				get_node("StartCount").text = str(countdown)
		else:
			return
	if (time * moves_per_second <= 0.9):
		return; #slow inputs to moves per second
	time = 0
	if gameover:
#		OS.delay_msec(1)
		return
	if paused:
		return
		
	var updatefood = false;
	for x in numplayers:
		colmap = emptyboard.duplicate()
		for x1 in numplayers:
			for s in snakes[x1]["truecords"].size():
				colmap[pos2index(snakes[x1]["truecords"][s])] = 1
				colmap[pos2index(foodpoly.position)] = 2
		if x == 0 && player1Ctrl == 0:
			get_input(x) #called in proccess as well
		else:
			ai_get_input(x) #only called here
		snakes[x]["truedir"] = snakes[x]["reqdir"]
		snakes[x]["tilerot"][0] = snakes[x]["truedir"]  #rotate old head to current dir
		var oldtailcord = snakes[x]["truecords"][snakes[x]["snakelen"]-1]
		var oldsnakesrot = snakes[x]["tilerot"][snakes[x]["snakelen"]-1]

		#Follow Head

		body_follow_head(x)
		#Move Head,
		move_head(x, snakes[x]["truedir"] )

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
			updatefood = true
			snakes[x]["snakecap"] += FoodSegments
	if updatefood:
		move_food()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gameover:
		return
	for x in numplayers:
		for s in snakes[x]["truecords"].size():
			tile_update_from_true(x, s)
		if x == 0 && player1Ctrl == 0:
			get_input(x)

func _on_GameOver_pressed():
	reset()
	get_node("GameOver").visible = false
	pass # Replace with function body.
