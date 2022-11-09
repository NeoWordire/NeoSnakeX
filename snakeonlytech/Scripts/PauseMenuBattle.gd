extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_paused = false setget set_is_paused

var selected = 0

func ready():
	is_paused = false

func _unhandled_input(event):
	var snakebattle = get_parent().get_parent().get_node("SnakeBattle")
	if snakebattle.currentBattleState == snakebattle.BATTLESTATE.STATE_BATTLING:
		if event.is_action_pressed("ui_pause"):
			self.is_paused = !is_paused
		if self.is_paused:
			if event.is_action_pressed("ui_accept"):
				self.is_paused = false


func _process(delta):
	pass

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	selected = 0
