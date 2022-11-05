extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout",get_parent().get_parent(),"end_con", ["timer"])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_parent().BattleState == 2 && $Timer.is_paused():
		$Timer.start(get_parent().get_parent().EndConditions["TIMER"])
	pass
