extends Control

export (String) var NextScene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for segment in $Snake.get_children():
		segment.modulate = get_node("PanelContainer/ColorPicker").color
		GlobalSnakeVar.g_colorPicked[0] = get_node("PanelContainer/ColorPicker").color
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene(NextScene)
	pass
