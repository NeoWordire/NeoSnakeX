extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selected = 1
var levelmax = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	selected = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://BattleScene/battle" + String(selected) + ".tscn")
	if Input.is_action_just_pressed("ui_down"):
		if (selected < 3):
			selected += 1
	if Input.is_action_just_pressed("ui_up"):
		if (selected > 1):
			selected -= 1
	get_node("arrow").position.y = get_node("battle" + String(selected)).rect_position.y + get_node("battle" + String(selected)).rect_size.y/2
	pass
