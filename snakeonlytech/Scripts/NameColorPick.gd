extends Control

export (String) var NextScene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func recurse_get_children(ctrl):
	for child in ctrl.get_children():
		if child is Container:
			print("> ", child)
			recurse_get_children(child)
		else:
			if child.get_class() != "HSlider":
				print("    ", child)
				child.visible = false
			else:
				print("   ", child)

# Called when the node enters the scene tree for the first time.
func _ready():
	#recurse_get_children($PanelContainer)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var color = Color.from_hsv(100.0 - $PanelContainer/VBoxContainer/HSlider.value/100.0, 1, 1, 1)

	for segment in $PanelContainer/VBoxContainer/Snake.get_children():
		segment.modulate = color
		GlobalSnakeVar.g_colorPicked[0] = color
	#	pass
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene(NextScene)
	pass
