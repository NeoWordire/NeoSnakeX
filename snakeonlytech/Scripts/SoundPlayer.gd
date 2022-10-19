extends Node
#https://www.youtube.com/watch?v= 5OElRG1YgjU
onready var audioPlayers = $AudioPlayers
const SFXSHOOT = preload("res://Assets/SFX/sfx_shoot.wav")
const SFXHURT = preload("res://Assets/SFX/sfx_hit.wav")
const SFXHURT2 = preload("res://Assets/SFX/sfx_body_part_lost.wav")
const SFXSNAKEDEFEATED = preload("res://Assets/SFX/sfx_snake_defeated.wav")
const SFXFOODPICKUP = preload("res://Assets/SFX/sfx_food_pickup.wav")


func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if !audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
