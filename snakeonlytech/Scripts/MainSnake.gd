extends CanvasLayer
const Bullet  = preload("res://Scripts/Bullet.gd")
const Snake = preload("res://Scripts/Snake.gd")
const Food = preload("res://Scripts/Food.gd")

# Declare member variables here. Examples:
export (int) var bullet_mps = 20
export (int) var snake_mps = 12
export (int) var FoodSegments = 1
export (bool) var debugging = false
export (float) var ShootCooldown = 0.5 

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("BGM").stream_paused = true
	GlobalSnakeVar.g_bullet_moves_per_second = bullet_mps
	GlobalSnakeVar.g_snake_moves_per_second = snake_mps
	GlobalSnakeVar.g_FoodSegments = FoodSegments
	GlobalSnakeVar.g_debugging = debugging
	GlobalSnakeVar.g_shoot_cooldown = ShootCooldown
	GlobalSnakeVar.debug = debugging
	GlobalSnakeVar.g_foodsegments = FoodSegments
	GlobalSnakeVar.g_rng.randomize()
	reset()
	pass # Replace with function body.

func reset():
	get_node("GameOver").visible = false
	GlobalSnakeVar.paused = false
	GlobalSnakeVar.initColMap()
	if (GlobalSnakeVar.snakes.empty()):
		var player = 0
		for node in get_children():
			print(node.get_class())
			if node.get_class() == "Snake":
				node.setup(player)
				player += 1
				#node.connect("snake_died", self, "snake_died_func")
				GlobalSnakeVar.snakes.append(node)
		GlobalSnakeVar.g_numplayers = player
	else:
		for snake in GlobalSnakeVar.snakes:
			snake.setup(snake._player)
	print(GlobalSnakeVar.snakes.size())

	var food = get_node("Food");
	food.ate_food()
	GlobalSnakeVar.foodpoly = food
	
func _process(_delta):
	if Input.is_action_just_released("ui_end"):
		GlobalSnakeVar.debug = !GlobalSnakeVar.debug

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
		#if !GlobalSnakeVar.bullets.empty():
		var time = OS.get_ticks_usec()
		GlobalSnakeVar.g_time_between_bullet = time - bulletlastrun
		bulletlastrun = time
		GlobalSnakeVar.bulletupdatetimer = 0

func _on_GameOver_pressed():
	reset()

func _on_Player_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("player = ", player, "has DIED")
	get_node("GameOver").visible = true
	get_node("GameOver").raise()
	GlobalSnakeVar.paused = true
	

func _on_Enemy_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("player = ", player, "has DIED")
	get_node("GameOver").visible = true
	get_node("GameOver").raise()
	GlobalSnakeVar.paused = true
	pass
