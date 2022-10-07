extends KinematicBody2D

export (int) var speed = 200
export (bool) var battleactive = false;
var count = 0

var velocity = Vector2()
var start = self.position
func reset():
	position = start

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	if !battleactive:
		return;
	get_input()
	var collision = move_and_collide(velocity*delta)
	if collision && collision.collider.name == "Goal":
	  get_parent().get_node("EndbattleButton").visible = true
	  battleactive = false;
