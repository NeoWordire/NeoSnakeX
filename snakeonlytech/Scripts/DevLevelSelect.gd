extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selected = 0
var levels = [
	"res://BattleScene/snakebattlev3.tscn",
	"res://BattleScene/battle1.tscn",
	"res://Shop/Shop.tscn",
	"res://Dialogue/TalkTemplate.tscn",
]

var levelpanels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = 0
	for x in levels.size():
		print(levels[x].rsplit("/")[-1].get_slice(".",0))
		
		var panel = PanelContainer.new()
##		polygon.polygon = PoolVector2Array([
#			Vector2(0,0),
#			Vector2(0,20),
#			Vector2(100,20),
#			Vector2(100,0)
#		])
		panel.rect_size = Vector2(100,16)
		panel.rect_position = Vector2(GlobalSnakeVar.width/2 - 100/2, x*24 + 30)
		var coolbox = load("res://Assets/Fonts/textboxstyletexture.tres")
		panel.set("custom_styles/panel", coolbox)
		var label = Label.new()
		label.text = levels[x].rsplit("/")[-1].get_slice(".",0)
		var cooltext = load("res://Assets/Fonts/ImprovGOLD.tres")
		label.set("custom_fonts/font", cooltext)
		panel.add_child(label)
		add_child(panel)
		levelpanels.append(panel)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene(levels[selected])
	if Input.is_action_just_pressed("ui_down"):
		if (selected < levels.size()-1):
			selected += 1
	if Input.is_action_just_pressed("ui_up"):
		if (selected > 0):
			selected -= 1
	get_node("arrow").position.y = levelpanels[selected].rect_position.y + levelpanels[selected].rect_size.y/2
	if get_node("arrow").position.y > 140 :
		self.rect_position.y = -140
	else :
		self.rect_position.y = 0
	pass
