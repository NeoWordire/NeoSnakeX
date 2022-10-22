extends CanvasLayer
const Bullet  = preload("res://Scripts/Bullet.gd")
const Snake = preload("res://Scripts/Snake.gd")
const Food = preload("res://Scripts/Food.gd")

# Declare member variables here. Examples:
export (int) var bullet_mps = 12
export (int) var snake_mps = 8
export (int) var FoodSegments = 1
export (bool) var debugging = false
export (float) var ShootCooldown = 0.5 
export (float) var timer = 30.0
var battleState = 0 # 0 == PRESTART, 1 == IN BATTLE, 2 GAMEOVER LOST, 3 GAMEOVERWIN


var timerinstance
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
	#beginFight()
	GlobalSnakeVar.paused = true
	pre_start()
	pass # Replace with function body.

func start():
	GlobalSnakeVar.paused = false

func beginFight():
	timerinstance = timer
	get_node("PRESTART").visible = false
	battleState = 1
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
	if Input.is_action_just_released("ui_accept"):
		if battleState == 0:
			startRequested()
		if battleState == 2:
			pre_start()
		if battleState == 3:
			#breakpoint # NEXT SCENE
			pass
	if (!GlobalSnakeVar.paused):
		get_node("HUD").get_node("CountdownTimer").text = String(ceil(timerinstance))
		timerinstance -= _delta

var bulletlastrun = 0
var counterlastsnake = 0
func _physics_process(delta):
	counterlastsnake += 1
	GlobalSnakeVar.snakeupdatetimer += delta
	GlobalSnakeVar.bulletupdatetimer += delta
	if GlobalSnakeVar.paused:
		return
	if (timerinstance <= 0.0):
		timerinstance = 0
		timer_complete()
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
	beginFight()
	
func startRequested():	
	beginFight()

func timer_complete():
	if (GlobalSnakeVar.snakes[0].sprites.size() < GlobalSnakeVar.snakes[1].sprites.size()):
		game_over_lost("YOUR SNAKE SMALL")
		return
	battleState = 3
	get_node("WINSCREEN").visible = true

func pre_start():
	battleState = 0
	get_node("LOSESCREEN").visible = false
	get_node("WINSCREEN").visible = false
	get_node("PRESTART").visible = true
	get_node("PRESTART").raise()
	
func game_over_lost(reason):
	battleState = 2
	print("LOST BECAUSE =", reason)
	GlobalSnakeVar.paused = true
	get_node("LOSESCREEN").visible = true
	get_node("WINSCREEN").visible = false
	get_node("LOSESCREEN/REASON").text = "GAMEOVER \n " + reason
	get_node("LOSESCREEN").raise()
	
func _on_Player_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("player = ", player, "has DIED")
	game_over_lost("YOU CRASHED")

func _on_Enemy_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("player = ", player, "has DIED")
	game_over_lost("WTF ENEMY DIED????????????????????????/")
	pass
