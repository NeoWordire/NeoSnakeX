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
	"ENEMYDESTROYED" : 0
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
var BattleState = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	BattleState = 0
	
func setupRound():
	for snakes in get_children():
		if snakes.get_class() == "SnakeActor":
			snakes.setupRound()
			pass
	#Show instructions XXX
	BattleState = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (BattleState == 0):
		print("Show Instructions")
		setupRound()
		BattleState = 1
	elif (BattleState == 1):
		if (Input.is_action_just_pressed("ui_accept")):
			#CLEAR INSTRUCTION
			BattleState = 2
	if (BattleState == 3):
		if (Input.is_action_just_pressed("ui_accept")):
			#CLEAR INSTRUCTION
			BattleState = 0	
	pass

var time_since_step = 0.0
func _physics_process(delta):
	if (BattleState == 2):
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

func _on_snake_died(player):
	print("Player: ", player," died")
	BattleState = 3
