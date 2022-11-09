extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout",get_parent().get_parent(),"end_condition", ["Timer ran out,\n"])
	pass # Replace with function body.


var started = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_parent().currentBattleState == get_parent().get_parent().BATTLESTATE.STATE_BATTLING && !started:
		#$Timer.start(get_parent().get_parent().EndConditions["TIMER"])
		$Timer.start(get_parent().get_parent().EndConditions["TIMER"])
		started = true
	if get_parent().get_parent().currentBattleState == get_parent().get_parent().BATTLESTATE.STATE_BATTLING && started:
		text = String(ceil($Timer.time_left))
	if get_parent().get_parent().currentBattleState != get_parent().get_parent().BATTLESTATE.STATE_BATTLING:
		started = false
	pass
