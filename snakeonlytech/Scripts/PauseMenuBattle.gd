extends Control

export(Array, NodePath) var Options
export(NodePath) var Arrow
export(NodePath) var BGM
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_paused = false setget set_is_paused

var selected = 0

func ready():
	visible = false

func _unhandled_input(event):
	if GlobalSnakeVar.g_battleState == 1:
		if event.is_action_pressed("ui_pause"):
			self.is_paused = !is_paused
			pass
		if self.is_paused && event.is_action_pressed("ui_accept"):
			if (selected == 0):
				self.is_paused = false
			if (selected == 1):
				get_node(BGM).playing = !get_node(BGM).playing
				print("pause or unpause")
			pass


func _process(delta):
	if Input.is_action_pressed("ui_down"):
		if (selected < Options.size()-1):
			selected += 1
	if Input.is_action_pressed("ui_up"):		
		if (selected > 0):
			selected -= 1
	get_node(Arrow).position.y = get_node(Options[selected]).rect_position.y + get_node(Options[selected]).rect_size.y/2 

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	selected = 0
