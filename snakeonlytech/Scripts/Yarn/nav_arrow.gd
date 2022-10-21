### A Simple button that pulses up and down at the specified interval
extends Control


var elapsed : float = 0
var startingPosition : Vector2
var inOptions = false
var selectedOption = 1
var curOptions = []

func _ready():
	startingPosition = rect_position
	visible = false
	pass

func show_button():
	get_tree().root.get_node("YarnDisplay").update()
	elapsed = 0
	visible = true

func hide_button():
	visible = false

func _process(delta):
	if (inOptions):
		#var number_ioget_parent().get_parent().get_parent()._options.size())
	#rect_position.y = startingPosition.y + (amplitude * sin(elapsed * ((2 * PI) / period)))
		if(Input.is_action_just_pressed("ui_accept")):
			get_parent().get_parent().get_parent().select_option(selectedOption-1)
		if(Input.is_action_just_pressed("ui_down") && selectedOption < curOptions.size()):
			selectedOption += 1
		if(Input.is_action_just_pressed("ui_up") && selectedOption > 1):
			selectedOption -= 1
		var optionstr = "Option" + String(selectedOption)
		if(get_parent().get_node("Options").get_node(optionstr)):
			rect_position.y = get_parent().get_node("Options").get_node(optionstr).rect_position.y
	else:
		if(Input.is_action_just_pressed("ui_accept")):
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
