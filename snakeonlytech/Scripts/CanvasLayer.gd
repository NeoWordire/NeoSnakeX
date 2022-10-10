extends CanvasLayer


# Declare member variables here. Examples:
export (int) var width = 240
export (int) var height = 160
export (Texture) var tex
export (Texture) var foodtex
# var a = 2
# var b = "text"
var dir = 5 # N E S W #TODO ENUM
var olddir
var time = 0
export (float) var control_speed = 0.02 #
const tilesize = 8
var playersnake = []
var playercords = []
var playerrot = []
var playercolarea = []
var snakelen = 0
var snakecap = 15
var colmap = []
var gameover = false
var foodpoly
var rng = RandomNumberGenerator.new()

export (Vector2) var startpos = Vector2(tilesize,tilesize)

func grow():
	var poly = Polygon2D.new()
	poly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	poly.set_texture(tex)
	if playersnake.size() == 0 :
		poly.position = startpos
	else :
		poly.position = playersnake[-1].position
	playersnake.append(poly)
	playercords.append(poly.position)
	colmap[(poly.position.y * height /8) + (poly.position.x/8)] = 1
	playerrot.append(5)
	var area = Area2D.new()
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(.1, .1))
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	add_child(area)
	area.add_child(collision)
	playercolarea.append(area)
	snakelen += 1
	add_child(poly)
	
func add_food():
	remove_child(foodpoly)
	foodpoly = Polygon2D.new()
	foodpoly.polygon = PoolVector2Array([
		Vector2(0,0),
		Vector2(0,tilesize),
		Vector2(tilesize,tilesize),
		Vector2(tilesize,0)
	])
	foodpoly.set_texture(foodtex)
	foodpoly.position.x = rng.randi_range(0,width/tilesize)*tilesize
	foodpoly.position.y = rng.randi_range(0,height/tilesize)*tilesize
	colmap[(foodpoly.position.y * height /8) + (foodpoly.position.x/8)] = 2
	add_child(foodpoly)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for w in width:
		for h in height:
			colmap.append(0);
	grow()
	add_food()
	pass # Replace with function body.

func gameover():
	gameover = true
	get_node("GameOver").visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if gameover:
		return
	get_input();
	if (dir == 5):
		return
	if time < control_speed:
		return;
	time = 0
	if (snakelen< snakecap):
		grow()
	else:
		colmap[(playercords[-1].y * height / 8) + (playercords[-1].x / 8)] = 0
	
	for i in snakelen:
		playersnake[i].position = playercords[i]
		playercolarea[i].position = playercords[i]
		if playerrot[i] == 0: #North
			#playersnake[i].position.x = playercords[i].x + 1
			playersnake[i].position.y = playercords[i].y + tilesize
			playersnake[i].rotation = deg2rad(270)
		if playerrot[i] == 1: #WEST
			playersnake[i].rotation = deg2rad(0)
			pass
		if playerrot[i] == 2: #SOUTH
			#[i].position.x = playercords[i].x - 1
			playersnake[i].position.x = playercords[i].x + tilesize
			playersnake[i].rotation = deg2rad(90)
		if playerrot[i] == 3: #EAST
			playersnake[i].rotation = deg2rad(180)
			playersnake[i].position.x = playercords[i].x + tilesize
			playersnake[i].position.y = playercords[i].y + tilesize
	if (dir == 0):
		#playersnake[0].rotation = deg2rad(270)
		playercords[0].y -= 1 * tilesize
	if (dir == 2):
		#playersnake[0].rotation = deg2rad(90)
		playercords[0].y += 1 * tilesize
	if (dir == 1):
		playercords[0].x += 1 * tilesize
	if (dir == 3):
		#playersnake[0].rotation = deg2rad(180)
		playercords[0].x -= 1 * tilesize
	if (colmap[(playercords[0].y * height /8) + (playercords[0].x/8)] == 1):
		print("ded")
		gameover()
		return
	if (colmap[(playercords[0].y * height /8) + (playercords[0].x/8)] == 2):
		print("Food GOT")
		add_food()
		snakecap += 10
		return
	playerrot[0] = dir
	for i in snakelen-1:
		var inverse = snakelen - i - 1
		#colmap[(playercords[inverse].y * height / 8) + (playercords[inverse].x / 8)] = 0
		playercords[inverse] = playercords[inverse-1] 
		colmap[(playercords[inverse].y * height / 8) + (playercords[inverse].x / 8)] = 1
		playerrot[inverse] = playerrot[inverse-1]
		#playersnake[inverse].position = playersnake[inverse - 1].position
		#playersnake[inverse].rotation = playersnake[inverse - 1].rotation
	colmap[(playercords[0].y * height / 8) + (playercords[0].x / 8)] = 1
func get_input():
	# velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		if (dir != 1) && (dir != 3):
		  dir = 1
	if Input.is_action_pressed("ui_left"):
		if (dir != 1) && (dir != 3):
		  dir = 3
	if Input.is_action_pressed("ui_down"):
		if (dir != 0) && (dir != 2):
		  dir = 2
	if Input.is_action_pressed("ui_up"):
		if (dir != 0) && (dir != 2):
		  dir = 0
	#velocity = velocity.normalized() * speed
