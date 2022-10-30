
extends Camera2D


onready var shakeTimer = $Timer
onready var tween = $Tween

var shake_amount = 0
var default_offset = Vector2(0,0)


func _ready():
	GlobalSnakeVar.g_camera = self


func _process(delta):
	offset = Vector2(rand_range(-shake_amount, shake_amount), rand_range(-shake_amount, shake_amount)) * delta + default_offset


func shake(new_shake, shake_time, shake_limit):
	print("SHAKE")
	shake_amount += float(new_shake)
	if shake_amount > float(shake_limit):
		shake_amount = float(shake_limit)
	
	shakeTimer.wait_time = float(shake_time)
	
	tween.stop_all()
	shakeTimer.start()


func _on_Timer_timeout():
	shake_amount = 0
	
	tween.interpolate_property(self, "offset", offset, default_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
