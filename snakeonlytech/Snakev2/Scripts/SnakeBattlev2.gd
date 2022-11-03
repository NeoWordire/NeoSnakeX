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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
export (float) var snakeStepsPerSec = 10.0
export (int) var modFoodSegments = 1

var time_since_step = 0.0
func _physics_process(delta):
	time_since_step += delta
	if (time_since_step*snakeStepsPerSec >= 1.0):
		time_since_step = 0.0
		for snakes in get_children():
			if snakes.get_class() != "SnakeActor":
				continue
			snakes.iterateNext = true
	pass


func _on_Food_ate_food(player):
	player.snakecap += modFoodSegments
	pass # Replace with function body.
