extends CanvasLayer
#const Bullet  = preload("res://Scripts/Bullet.gd")
#const Snake = preload("res://Scripts/Snake.gd")
#const Food = preload("res://Scripts/Food.gd")

export (String) var WinScene = "res://DevLevelSelect.tscn"

# Declare member variables here. Examples:
#export (int) var bullet_mps = 12
#export (int) var snake_mps = 8
#export (int) var FoodSegments = 1
export (bool) var debugging = false
#export (float) var ShootCooldown = 0.5 
#export (float) var timer = 30.0 EndConditions["TIMER"]

enum battleStateEnum {PRESTART, INBATTLE,ROUNDOVER,GAMEOVERLOST,GAMEOVERWON}

#not used outside doucmentation rn
var WinLoseEndCons = [
	"APPLES", #0 no checks, >0 end game once this many apples collected
	"SEGMENTS", #0 not checked, #1 (on end) Compare and player must have more segments
	"TIMER", #0 no timer, >0 end game after this many seconds
	"ENEMYDESTROYED", #0 no end, 1 if any snake size == 2
]

export (Dictionary) var ModConditions = {
	"BulletMps" : 12,
	"SnakeMps" : 8,
	"ShootDisabled" : false,
	"ShootCooldown" : 1.0,
	"FoodSegmentsGain" : 1,
}

export (Dictionary) var WinConditions = {
	"APPLES" : 0,
	"SEGMENTS" : 1,
}

export (Dictionary) var EndConditions = {
	"TIMER" : 30,
	"ENEMYDESTROYED" : 0
}

export (bool) var bestOfThree = true
var bestOfTracker = [0,0]

var timerinstance
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSnakeVar.g_battleState = battleStateEnum.PRESTART
	GlobalSnakeVar.paused = true
	GlobalSnakeVar.bullets = []
	#get_node("BGM").stream_paused = true
	GlobalSnakeVar.g_debugging = debugging
	GlobalSnakeVar.g_bullet_moves_per_second = ModConditions["BulletMps"]
	GlobalSnakeVar.g_snake_moves_per_second = ModConditions["SnakeMps"]
	GlobalSnakeVar.g_shoot_cooldown = ModConditions["ShootCooldown"]
	GlobalSnakeVar.g_foodsegments = ModConditions["FoodSegmentsGain"]
	GlobalSnakeVar.g_rng.randomize()
	#beginFight()
	pre_start()
	pass # Replace with function body.

func start():
	GlobalSnakeVar.paused = false

func beginFight():
	if (EndConditions["TIMER"] != 0):
		timerinstance = EndConditions["TIMER"]
	get_node("PRESTART").visible = false
	GlobalSnakeVar.g_battleState = battleStateEnum.INBATTLE
	GlobalSnakeVar.paused = false
	#GlobalSnakeVar.initColMap()
	GlobalSnakeVar.initAstar()
	GlobalSnakeVar.g_boardSprites = {}
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
		if (EndConditions["TIMER"] != 0):
			get_node("HUD").get_node("CountdownTimer").text = String(abs(ceil(timerinstance)))
			timerinstance -= _delta
		get_node("HUD").get_node("Player/Score").text = "X" + String(GlobalSnakeVar.snakes[0].sprites.size())
		get_node("HUD").get_node("Enemy/Score").text = "X" + String(GlobalSnakeVar.snakes[1].sprites.size())

	uiCooldown += _delta
	uiCooldown += _delta
	if (uiCooldown > 0.5 || GlobalSnakeVar.g_battleState == battleStateEnum.GAMEOVERWON):
		if Input.is_action_just_pressed("ui_accept"):
			if GlobalSnakeVar.g_battleState == battleStateEnum.PRESTART: #start from zero
				startRequested()
			#GlobalSnakeVar.g_battleState == 1 in battle
			if GlobalSnakeVar.g_battleState == battleStateEnum.ROUNDOVER: #continmu best of 3
				pre_start()
			if GlobalSnakeVar.g_battleState == battleStateEnum.GAMEOVERLOST: #lost best of 3
				pre_start() 
			if GlobalSnakeVar.g_battleState == battleStateEnum.GAMEOVERWON: #won best of 3
				get_tree().change_scene(WinScene)
			uiCooldown = 0.0
var bulletlastrun = 0
var counterlastsnake = 0

func _physics_process(delta):
	counterlastsnake += 1
	GlobalSnakeVar.snakeupdatetimer += delta
	GlobalSnakeVar.bulletupdatetimer += delta
	if GlobalSnakeVar.paused:
		return
	if (EndConditions["TIMER"] != 0 && timerinstance <= 0.0):
		timerinstance = 0
		end_con_hit()
		return
		#if (updatetime*GlobalSnakeVar.moves_per_second >= 1.0):
	if (GlobalSnakeVar.snakeupdatetimer * GlobalSnakeVar.g_snake_moves_per_second >= 1.0):
		var anyDied = false
		for snake in GlobalSnakeVar.snakes:
			snake.decide_turn()
			if (snake.play_movement()):
				anyDied = true
		if anyDied:
			GlobalSnakeVar.paused = true
			return
		for snake in GlobalSnakeVar.snakes:
			snake.update_display()
				#GlobalSnakeVar.paused = true
		GlobalSnakeVar.g_counterlastsnake = counterlastsnake
		counterlastsnake = 0
		if GlobalSnakeVar.g_debugging:
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
	
func startRequested():	
	beginFight()
	
func end_con_hit():
	clean_up_before_change()
	if (WinConditions["SEGMENTS"] == 1):
		if (GlobalSnakeVar.snakes[0].sprites.size() == GlobalSnakeVar.snakes[1].sprites.size()):
			round_over_lost("TIED, CLOSE BUT NOT A VICTORY...")
			return
		elif (GlobalSnakeVar.snakes[0].sprites.size() < GlobalSnakeVar.snakes[1].sprites.size()):
			round_over_lost("YOUR SNAKE SMALL")
			return
		else:
			round_over_won("BIGGER SNAKE DIPLOMACY, YOU WON")
	else:
		round_over_won("ERROR NO WIN CONDITION HIT SO THIS BATTLE NEEDS A WIN CON?")
		
func round_over_won(reason):
	uiCooldown = 0.0
	GlobalSnakeVar.g_battleState = battleStateEnum.GAMEOVERWON
	get_node("WINSCREEN").visible = true
	get_node("WINSCREEN/REASON").text = reason

func pre_start():
	uiCooldown = 0.0
	GlobalSnakeVar.g_battleState = battleStateEnum.PRESTART
	get_node("LOSESCREEN").visible = false
	get_node("WINSCREEN").visible = false
	get_node("PRESTART").visible = true
	get_node("PRESTART").raise()

func game_over_lost(reason):
	clean_up_before_change()
	print("LOST BECAUSE =", reason)
	GlobalSnakeVar.paused = true
	get_node("LOSESCREEN").visible = true
	get_node("WINSCREEN").visible = false
	get_node("LOSESCREEN/REASON").text = "GAMEOVER \n " + reason
	get_node("LOSESCREEN").raise()

	pass
	
func game_over_won():
	pass

func round_over_lost(reason):
	uiCooldown = 0.0
	GlobalSnakeVar.g_battleState = 2
	game_over_lost(reason)

func clean_up_before_change():
	for bullet in GlobalSnakeVar.bullets:
		bullet.queue_free()
	GlobalSnakeVar.bullets = []	

func _on_Player_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("player = ", player, "has DIED")
	round_over_lost("YOU CRASHED")

func _on_Enemy_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	
	print("player = ", player, "has DIED")
	#game_over_lost("WTF ENEMY DIED????????????????????????/")
	uiCooldown = 0.0
	GlobalSnakeVar.g_battleState = 3
	get_node("WINSCREEN").visible = true
	pass
