extends Control


# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.visible = false
	pass # Replace with function body.

func _on_SnakeBattle_state_changed(state):
	for child in get_children():
		child.visible = false
	if (state == get_parent().BATTLESTATE.STATE_SHOWING_INSTRUCT):
		$PRESTART.visible = true
	if (state == get_parent().BATTLESTATE.STATE_POST_ROUND_SCORE):
		if get_parent().bestOfThree:
			$ROUNDSCORE/PanelContainer/RichTextLabel.text = get_parent().lastReason
			$ROUNDSCORE/PanelContainer/RichTextLabel.text += "\nThe best of three score:\n"
			$ROUNDSCORE/PanelContainer/RichTextLabel.text += "You   Them\n"
			$ROUNDSCORE/PanelContainer/RichTextLabel.text += " " + String(get_parent().bestOfTracker[0]) + "     " + String(get_parent().bestOfTracker[1])
			#$ROUNDSCORE/PanelContainer/RichTextLabel.text += String(get_parent().bestOfTracker)
		$ROUNDSCORE.visible = true	
	if (state == get_parent().BATTLESTATE.STATE_WIN):
		$WINSCREEN.visible = true
	if (state == get_parent().BATTLESTATE.STATE_LOSS):
		$LOSESCREEN/MAIN/REASON.text = "GAMEOVER \n"
		$LOSESCREEN/MAIN/REASON.text += get_parent().lastReason
		$LOSESCREEN/MAIN/REASON.text += "\nThe Final score:\n"
		$LOSESCREEN/MAIN/REASON.text += "You   Them\n"
		$LOSESCREEN/MAIN/REASON.text += " " + String(get_parent().bestOfTracker[0]) + "     " + String(get_parent().bestOfTracker[1])
		$LOSESCREEN.visible = true
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	pass

