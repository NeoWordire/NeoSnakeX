### A Simple button that pulses up and down at the specified interval
extends Button

var elapsed : float = 0
var startingPosition : Vector2

func _ready():
	startingPosition = rect_position
	pass

func show_button():
	get_parent().update()
	elapsed = 0
	visible = true


func hide_button():
	visible = false

func _process(delta):
	elapsed+=delta
