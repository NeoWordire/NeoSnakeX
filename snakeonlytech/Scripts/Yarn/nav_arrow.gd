### A Simple button that pulses up and down at the specified interval
extends Control


var elapsed : float = 0
var startingPosition : Vector2
var inOptions = false
var inUpgrades = false
var selectedOption = 1
var choosenOption = -1
var curOptions = []

export (String) var EndScene

signal finish_line_early

var upgradeDesc = ["GUN 1 DESC,GUN 1 DESC,GUN 1 DESC,GUN 1 DESC,GUN 1 DESC", "GUN 2 DESC,GUN 2 DESC,GUN 2 DESC,GUN 2 DESC,GUN 2 DESC", "GUN 3 DESC,GUN 3 DESC,GUN 3 DESC,GUN 3 DESC,GUN 3 DESC"]

func _ready():
	startingPosition = rect_position
	visible = false
	get_parent().get_parent().visible = false
	pass

func show_button():
	get_tree().root.get_node("YarnDisplay").update()
	elapsed = 0
	visible = true

func hide_button():
	visible = false

var uiCooldown = 0.0
func _process(delta):
	uiCooldown += delta
	if (inOptions && uiCooldown > 1.0):
		#var number_ioget_parent().get_parent().get_parent()._options.size())
		#rect_position.y = startingPosition.y + (amplitude * sin(elapsed * ((2 * PI) / period)))
		if(Input.is_action_just_pressed("ui_accept")):
			inUpgrades = false
			get_parent().get_parent().get_parent().select_option(selectedOption-1)
			choosenOption = selectedOption-1
			uiCooldown = 0.0
			return
		if(Input.is_action_just_pressed("ui_down") && selectedOption < curOptions.size()):
			selectedOption += 1
		if(Input.is_action_just_pressed("ui_up") && selectedOption > 1):
			selectedOption -= 1
		var optionstr = "Option" + String(selectedOption)
		if(get_parent().get_node("Options").get_node(optionstr)):
			rect_position.y = get_parent().get_node("Options").get_node(optionstr).rect_position.y
	if (inUpgrades):
		get_parent().get_parent().get_parent().get_node("Dialogue/VBoxContainer/RichTextLabel").text = upgradeDesc[selectedOption-1]
	else:
		if(Input.is_action_just_pressed("ui_accept")):
			emit_signal("finish_line_early")
			get_parent().get_parent().get_parent().finish_line()
	elapsed+=delta


func _on_YarnDisplay_options_shown(OptionsShow):
	selectedOption = 1
	curOptions = OptionsShow
	get_parent().get_parent().visible = true
	visible = true
	inOptions = true
	print(curOptions)
	pass # Replace with function body.


func _on_YarnDisplay_option_selected():
	get_parent().get_parent().visible = false
	visible = false
	inOptions = false
	pass # Replace with function body.


func _on_YarnRunner_command_emitted(command, arguments):
	print("command = ", command, arguments)
	
	pass

func _on_YarnRunner_dialogue_finished():
	get_tree().change_scene(EndScene)
	pass # Replace with function body.
