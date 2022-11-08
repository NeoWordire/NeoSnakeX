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

# Called when the node enters the scene tree for the first time.
func _ready():
	currentBattleState = BATTLESTATE.STATE_INIT
	
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
		currentBattleState = BATTLESTATE.STATE_SHOWING_INSTRUCT
	elif (currentBattleState == BATTLESTATE.STATE_SHOWING_INSTRUCT):
		if (Input.is_action_just_pressed("ui_accept")):
			#CLEAR INSTRUCTION
			currentBattleState = BATTLESTATE.STATE_BATTLING
	if (currentBattleState == BATTLESTATE.STATE_POST_ROUND_SCORE):
		if (Input.is_action_just_pressed("ui_accept")):
			#CLEAR INSTRUCTION
			currentBattleState = BATTLESTATE.STATE_INIT
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
	print("Player: ", player," died")
	if (EndConditions["DEATHPERM"]):
		whodied = player
		end_condition("died")
	else:
		print("TODO RESPAWN?")

func end_condition(reason):
	if (whodied != -1):
		print(reason, "round end, ", whodied, " has died")
		bestOfTracker[(whodied+1)%2] += 1
		whodied = -1
	elif WinConditions["APPLES"] == 1:
		pass
	elif WinConditions["SEGMENTS"] == 1:
		if get_node("Snake/Body").get_child_count() == get_node("Enemy/Body").get_child_count():
			print(reason, "round end, tie on segcount, rematch")
		elif get_node("Snake/Body").get_child_count() > get_node("Enemy/Body").get_child_count():
			print(reason, "round end, winner seg")
			bestOfTracker[0] += 1
		else:
			print(reason, "round end, Loss seg")
			bestOfTracker[1] += 1
	if bestOfThree:
		if bestOfTracker[0] == 2:
			print("print best of 3, player won")
		elif bestOfTracker[1] == 2:
			print("print best of 3, enemy won")
			print("gameover, try again")
		else:
			print("print score ",  bestOfTracker, " then CONINTUE")
			currentBattleState = BATTLESTATE.STATE_POST_ROUND_SCORE
	else:
		if bestOfTracker[0] == 0:
			pass
		else:
			pass
