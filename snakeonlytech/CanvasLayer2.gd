extends CanvasLayer


# Declare member variables here. Examples:
export (int) var width = 240
export (int) var height = 160
export (float) var moves_per_second = 5  #Times per second to move?
export (Texture) var playerbodytex
export (Texture) var playerheadtexNOTUSED
export (int) var tilesize = 8
var playerstartpos = Vector2(tilesize,floor(height/2/tilesize)*tilesize - tilesize)
export (Texture) var foodtex
export (int) var FoodSegments = 5

enum {NORTH, EAST, SOUTH, WEST, NODIR}

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

var tempzero = []

## Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	get_node("GameOver").visible = false
	for w in width:
		for h in height:
			colmap.append(0);
	tempzero = colmap.duplicate()
	#optional make player under root Node2D
	#var node = Node2D.new()
	#node.name = "Player"
	#add_child(node)
	foodpoly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	grow(playerstartpos, EAST)
	foodpoly.set_texture(foodtex)
	add_child(foodpoly)
	move_food()
	pass # Replace with function body.

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
		poly.position = tailpos
	
	playersprites.append(poly)
	playertruecords.append(tailpos)
	colmap[tailpos.y*height/tilesize + tailpos.x] = 1
	add_child(poly)
	snakelen += 1
	
func move_food():
	foodpoly.position.x = rng.randi_range(0,width/tilesize - tilesize)*tilesize
	foodpoly.position.y = rng.randi_range(0,height/tilesize- tilesize)*tilesize
	if colmap[(foodpoly.position.y * height /tilesize) + (foodpoly.position.x/tilesize)] == 2:
		move_food();
#
func game_over():
	gameover = true
	var node = get_node("GameOver")
	remove_child(node)
	add_child(node)
	node.visible = true

func move_head(newdir):
	if (newdir == NORTH):
		playertruecords[0].y -= 1 * tilesize
		playersprites[0].position.x = playertruecords[0].x
		playersprites[0].position.y = playertruecords[0].y + tilesize
		playersprites[0].rotation = deg2rad(270)
	if (newdir == EAST):
		playertruecords[0].x += 1 * tilesize
		playersprites[0].position.x = playertruecords[0].x
		playersprites[0].position.y = playertruecords[0].y
		playersprites[0].rotation = deg2rad(0)
	if (newdir == SOUTH):
		playertruecords[0].y += 1 * tilesize
		playersprites[0].position.x = playertruecords[0].x + tilesize
		playersprites[0].position.y = playertruecords[0].y
		playersprites[0].rotation = deg2rad(90)
	if (newdir == WEST):
		playertruecords[0].x -= 1 * tilesize
		playersprites[0].position.x = playertruecords[0].x + tilesize
		playersprites[0].position.y = playertruecords[0].y + tilesize
		playersprites[0].rotation = deg2rad(180)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#time += delta
	#if time < control_speed:
	#	return;
	#print(delta*100000)
	
	#print("sleep ", (1000/control_speed)-delta*1000, " plus delta =", delta*1000)
	OS.delay_msec((1000/moves_per_second)-delta*1000)
	get_input();
	
	if (dir == NODIR):
		dir = EAST
	#print(time)
	time = 0
	if gameover:
		return
	var oldtailcord = playertruecords[-1]
	
	#Move Head,
	move_head(dir)
	if (playertruecords[0].x < 0 ||  playertruecords[0].x > width - tilesize ||
			playertruecords[0].y < 0 || playertruecords[0].y > height - tilesize):
		print("WALLDED")
		game_over()
	elif colmap[playertruecords[0].y*height/tilesize + playertruecords[0].x/tilesize] == 1:
		print("DED")
		game_over()
	elif colmap[playertruecords[0].y*height/tilesize + playertruecords[0].x/tilesize] == 2:
		print("FOOD")
		move_food()
		snakecap += FoodSegments
	
	if (snakelen< snakecap):
		grow(oldtailcord, dir)
#Follow Head
	for i in snakelen-1:
		var inverse = snakelen - i - 1
		playertruecords[inverse] = playertruecords[inverse-1] 
		playersprites[inverse].position = playersprites[inverse - 1].position
		playersprites[inverse].rotation = playersprites[inverse - 1].rotation

	# HACK, REPLACE with clean update code, rough hack to make colmap accurate
	colmap = tempzero.duplicate()
	for i in playertruecords.size():
		colmap[playertruecords[i].y*height/tilesize + playertruecords[i].x/tilesize] = 1
	colmap[(foodpoly.position.y * height /tilesize) + (foodpoly.position.x/tilesize)] = 2
	
func get_input():
	# velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		if (dir != WEST) && (dir != EAST):
		  dir = EAST
	if Input.is_action_pressed("ui_left"):
		if (dir != WEST) && (dir != EAST):
		  dir = WEST
	if Input.is_action_pressed("ui_down"):
		if (dir != NORTH) && (dir != SOUTH):
		  dir = SOUTH
	if Input.is_action_pressed("ui_up"):
		if (dir != NORTH) && (dir != SOUTH):
		  dir = NORTH
	#velocity = velocity.normalized() * speed

func _on_GameOver_pressed():
	for child in get_children():
		if child.name != "GameOver":
			child.queue_free()
	playersprites = []
	playertruecords = []
	playertilerot = []
#var playercolarea = []
	snakelen = 0
	snakecap = 5
	colmap = []
	gameover = false
	foodpoly = Polygon2D.new()
	dir = EAST
	_ready()
	pass # Replace with function body.
