extends Node2D

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
	"ENEMYDESTROYED" : 0,
	"DEATHPERM" : 1,
}

export (bool) var bestOfThree = true
var bestOfTracker = [0,0]
signal state_changed (state)

export (String) var WinScene


#battle states
#0 Leading
#1 showing instructions
#2 active battle
#3 paused
#4 round over
#5 bestof X over, lost
#6 brstof X over won
var currentBattleState = BATTLESTATE.STATE_INIT
enum BATTLESTATE {
	STATE_INIT,
	STATE_SHOWING_INSTRUCT,
	STATE_BATTLING,
	STATE_PAUSED,
	STATE_POST_ROUND_SCORE,
	STATE_WIN,
	STATE_LOSS,
	}
func setBattleState(newState):
	emit_signal("state_changed", newState)
	currentBattleState = newState

# Called when the node enters the scene tree for the first time.
func _ready():
	setBattleState(BATTLESTATE.STATE_INIT)
	
func setupRound():
	for snakes in get_children():
		if snakes.get_class() == "SnakeActor":
			snakes.setupRound()
			pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(currentBattleState)
	if (currentBattleState == BATTLESTATE.STATE_INIT):
		print("SETUP SHOW INSTRUCT")
		setupRound()
		setBattleState(BATTLESTATE.STATE_SHOWING_INSTRUCT)
	elif (currentBattleState == BATTLESTATE.STATE_SHOWING_INSTRUCT):
		if (Input.is_action_just_pressed("ui_accept")):
			setBattleState(BATTLESTATE.STATE_BATTLING)
	if (currentBattleState == BATTLESTATE.STATE_POST_ROUND_SCORE):
		if (Input.is_action_just_pressed("ui_accept")):
			setupRound()
			setBattleState(BATTLESTATE.STATE_BATTLING)
	if (currentBattleState == BATTLESTATE.STATE_LOSS):
		if (Input.is_action_just_pressed("ui_accept")):
			currentBattleState = BATTLESTATE.STATE_INIT
	if (currentBattleState == BATTLESTATE.STATE_WIN):
		if (Input.is_action_just_pressed("ui_accept")):
			get_tree().change_scene(WinScene)
	pass

var time_since_step = 0.0
func _physics_process(delta):
	if (currentBattleState == BATTLESTATE.STATE_BATTLING):
		time_since_step += delta
		if (time_since_step* ModConditions["SnakeMps"] >= 1.0):
			time_since_step = 0.0
			for snakes in get_children():
				if snakes.get_class() != "SnakeActor":
					continue
				snakes.iterateNext = true


func _on_Food_ate_food(player):
	player.snakecap += ModConditions["FoodSegmentsGain"]
	pass # Replace with function body.

var whodied = -1
func _on_snake_died(player):
	SoundPlayer.play_sound(SoundPlayer.SFXSNAKEDEFEATED)
	print("Player: ", player," died")
	if (EndConditions["DEATHPERM"]):
		whodied = player
		if (player == 0):
			end_condition("You Crashed, \nThey earned the win.\n")
		else:
			end_condition("They Crashed, \nYou earned a win.\n")
	else:
		print("TODO RESPAWN?")

var lastReason = ""
func end_condition(reason):
	lastReason = ""
	print("start end", bestOfTracker)
	if (whodied != -1):
		bestOfTracker[(whodied+1)%2] += 1
		whodied = -1
		lastReason = reason
	elif WinConditions["APPLES"] == 1:
		pass
	elif WinConditions["SEGMENTS"] == 1:
		if get_node("Snake/Body").get_child_count() == get_node("Enemy/Body").get_child_count():
			lastReason = lastReason + "tie on snake Size,\nNo one gets the win credit.\n"
		elif get_node("Snake/Body").get_child_count() > get_node("Enemy/Body").get_child_count():
			lastReason = lastReason + "You got the bigger snake\n You earned the win.\n"
			bestOfTracker[0] += 1
		else:
			lastReason = lastReason + "Enemy had the bigger snake\n They earned the win.\n"
			bestOfTracker[1] += 1
	print("end end", bestOfTracker)
	if bestOfThree:
		if bestOfTracker[0] == 2:
			print("print best of 3, player won")
			setBattleState(BATTLESTATE.STATE_WIN)
		elif bestOfTracker[1] == 2:
			print("print best of 3, enemy won")
			print("gameover, try again")
			setBattleState(BATTLESTATE.STATE_LOSS)
			bestOfTracker = [0,0]
		else:
			print("print score ",  bestOfTracker, " then CONINTUE")
			setBattleState(BATTLESTATE.STATE_POST_ROUND_SCORE)
	else:
		if bestOfTracker[0] == 0:
			pass
		else:
			pass
