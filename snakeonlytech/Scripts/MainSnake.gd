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
	GlobalSnakeVar.snakes = []
	var player = 0
	for node in get_children():
		print(node.get_class())
		if node.get_class() == "Snake":
			node.setup(player)
			player += 1
			#node.connect("snake_died", self, "snake_died_func")
			GlobalSnakeVar.snakes.append(node)
		GlobalSnakeVar.g_numplayers = player
	assert(GlobalSnakeVar.snakes.size()==2)

	var food = get_node("Food");
	food.ate_food()
	GlobalSnakeVar.foodpoly = food
	
var uiCooldown = 0.0
func _process(_delta):
	if (!GlobalSnakeVar.paused):
		#update hud
		get_node("HUD").get_node("CountdownTimer").text = String(abs(ceil(timerinstance)))
		get_node("HUD").get_node("Player/Score").text = "X" + String(GlobalSnakeVar.snakes[0].truecords.size())
		get_node("HUD").get_node("Enemy/Score").text = "X" + String(GlobalSnakeVar.snakes[1].truecords.size())
		timerinstance -= _delta
	uiCooldown += _delta
	if (uiCooldown > 0.5 || battleState == 3):
		if Input.is_action_just_pressed("ui_accept"):
			if battleState == 0:
				startRequested()
			if battleState == 2:
				pre_start()
			if battleState == 3:
				get_tree().change_scene("res://DevLevelSelect.tscn")
			uiCooldown = 0.0
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
	clean_up_before_change()
	if (GlobalSnakeVar.snakes[0].sprites.size() == GlobalSnakeVar.snakes[1].sprites.size()):
		game_over_lost("TIED, CLOSE BUT NOT A VICTORY...")
		return
	if (GlobalSnakeVar.snakes[0].sprites.size() < GlobalSnakeVar.snakes[1].sprites.size()):
		game_over_lost("YOUR SNAKE SMALL")
		return
	uiCooldown = 0.0
	battleState = 3
	get_node("WINSCREEN").visible = true

func pre_start():
	uiCooldown = 0.0
	battleState = 0
	get_node("LOSESCREEN").visible = false
	get_node("WINSCREEN").visible = false
	get_node("PRESTART").visible = true
	get_node("PRESTART").raise()
	
func clean_up_before_change():
	for bullet in GlobalSnakeVar.bullets:
		bullet.queue_free()
	GlobalSnakeVar.bullets = []	

func game_over_lost(reason):
	uiCooldown = 0.0
	battleState = 2
	clean_up_before_change()
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
	#game_over_lost("WTF ENEMY DIED????????????????????????/")
	uiCooldown = 0.0
	battleState = 3
	get_node("WINSCREEN").visible = true
	pass
