extends CanvasLayer
const Bullet  = preload("res://Scripts/Bullet.gd")
const Snake = preload("res://Scripts/Snake.gd")
const Food = preload("res://Scripts/Food.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#export (int) var numplayers = 2

export (int) var bullet_mps = 20
export (int) var snake_mps = 12
#export (StreamTexture) var playerbodytex
#export (StreamTexture) var playerheadtex
#export (StreamTexture) var enemybodytex
#export (StreamTexture) var enemyheadtex
#export (StreamTexture) var foodtex
export (int) var FoodSegments = 1
#export (int) var CountDownStart = 3
export (bool) var debugging = false
export (float) var ShootCooldown = 0.5 

#export (int, "player","ai") var player1Ctrl
#export var startpos = [
#		Vector2(GlobalSnakeVar.tilesize,
#				floor(GlobalSnakeVar.height/2/GlobalSnakeVar.tilesize)*
#						GlobalSnakeVar.tilesize - GlobalSnakeVar.tilesize), 
#		Vector2(GlobalSnakeVar.width - GlobalSnakeVar.tilesize *2,
#				floor(GlobalSnakeVar.height/2/GlobalSnakeVar.tilesize)*
#						GlobalSnakeVar.tilesize - GlobalSnakeVar.tilesize)
#	]
#export (Array, GlobalSnakeVar.DIRS) var startrot = [GlobalSnakeVar.DIRS.EAST, GlobalSnakeVar.DIRS.EAST]


# Called when the node enters the scene tree for the first time.
func _ready():
#	GlobalSnakeVar.g_playerbodytex = playerbodytex
#	GlobalSnakeVar.g_playerheadtex = playerheadtex
#	GlobalSnakeVar.g_enemybodytex = enemybodytex
#	GlobalSnakeVar.g_enemyheadtex = enemyheadtex
	GlobalSnakeVar.g_bullet_moves_per_second = bullet_mps
	GlobalSnakeVar.g_snake_moves_per_second = snake_mps
	#GlobalSnakeVar.g_numplayers = numplayers
	GlobalSnakeVar.g_FoodSegments = FoodSegments
	#GlobalSnakeVar.g_CountDownStart = CountDownStart
	GlobalSnakeVar.g_debugging = debugging
#	GlobalSnakeVar.g_startpos = startpos
	#GlobalSnakeVar.g_startrot = startrot
	#GlobalSnakeVar.g_player1Ctrl = player1Ctrl
	GlobalSnakeVar.g_shoot_cooldown = ShootCooldown
	GlobalSnakeVar.debug = debugging
	GlobalSnakeVar.g_foodsegments = FoodSegments
	GlobalSnakeVar.g_rng.randomize()
	reset()
	pass # Replace with function body.

func reset():
	get_node("GameOver").visible = false
	GlobalSnakeVar.paused = false
	#cntpaused = true
	#get_node("StartCount").visible = true
	#get_node("StartCount").text = str(countdown)
	#for s in GlobalSnakeVar.snakes:
	#	remove_child(s)
	#	s.queue_free()
	#GlobalSnakeVar.snakes = []
	GlobalSnakeVar.initColMap()
	if (GlobalSnakeVar.snakes.empty()):
		var player = 0
		for node in get_children():
			print(node.get_class())
			if node.get_class() == "Snake":
				node.setup(player)
				player += 1
				node.connect("snake_died", self, "snake_died_func")
			#add_child(node)
				GlobalSnakeVar.snakes.append(node)
		GlobalSnakeVar.g_numplayers = player
	else:
		for snake in GlobalSnakeVar.snakes:
			snake.setup(snake._player)
	print(GlobalSnakeVar.snakes.size())
#	for i in GlobalSnakeVar.g_numplayers:
#		var snake = Snake.new()
#		var headtex
#		var bodytex
#		if i == 0:
#			headtex = playerheadtex
#			bodytex = playerbodytex
#		else:
#			headtex = enemyheadtex
#			bodytex = enemybodytex
#		snake.setup(i)
#		#snake.sprites[0].texture = playerbodytex
#		snake.connect("snake_died", self, "snake_died_func")
#		add_child(snake)
#		GlobalSnakeVar.snakes.append(snake)
	#remove_child(GlobalSnakeVar.foodpoly)
	#GlobalSnakeVar.foodpoly.queue_free()
	var food = get_node("Food");
	#food.setup()
	food.ate_food()
	#add_child(food)
	GlobalSnakeVar.foodpoly = food
	
func _process(delta):
	if Input.is_action_just_released("ui_end"):
		GlobalSnakeVar.debug = !GlobalSnakeVar.debug

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var bulletlastrun = 0
var counterlastsnake = 0
func _physics_process(delta):
	counterlastsnake += 1
	GlobalSnakeVar.snakeupdatetimer += delta
	GlobalSnakeVar.bulletupdatetimer += delta
	if GlobalSnakeVar.paused:
		return
		#if (updatetime*GlobalSnakeVar.moves_per_second >= 1.0):
	if (GlobalSnakeVar.snakeupdatetimer * GlobalSnakeVar.g_snake_moves_per_second >= 1.0):
		for snake in GlobalSnakeVar.snakes:
			snake.step_simulation()
			if GlobalSnakeVar.paused:
				return
			snake.update_display()
				#GlobalSnakeVar.paused = true
		GlobalSnakeVar.g_counterlastsnake = counterlastsnake
		counterlastsnake = 0
		if GlobalSnakeVar.debug:
			GlobalSnakeVar.debug_colmap()
		#print("snaketime")
		GlobalSnakeVar.snakeupdatetimer = 0
	if (GlobalSnakeVar.bulletupdatetimer * GlobalSnakeVar.g_bullet_moves_per_second >= 1.0):
		for bullet in GlobalSnakeVar.bullets:
			bullet.step_simulation()
		if !GlobalSnakeVar.bullets.empty():
			var time = OS.get_ticks_usec()
			GlobalSnakeVar.g_time_between_bullet = time - bulletlastrun
			bulletlastrun = time
		GlobalSnakeVar.bulletupdatetimer = 0

func _on_GameOver_pressed():
	reset()
	get_node("GameOver").visible = false
	pass # Replace with function body.

#bullet.connect("bullet_moved", self, "check_bullet")

func snake_died_func(player):
	print("player = ", player, "has DIED")
	get_node("GameOver").visible = true
	get_node("GameOver").raise()
	GlobalSnakeVar.paused = true
	pass
