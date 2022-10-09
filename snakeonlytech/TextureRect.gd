extends TextureRect

# Declare member variables here.
export (int) var speed = 10
var dir = 0 # N E S W
var board = []
var image = Image.new()
var yousnakex = [];
var yousnakey = [];
var head = 0
var tail = 0
var size = 1;
var foodx = 20;
var foody = 10;
var maxsize = 20
var startx = 20
var starty = 12
var velocity = Vector2()
var stop = false
var blankcolor = Color(0, 0, 0, 1)
var snakecolor = Color(255, 0, 0, 1)
var foodcolor = Color(128, 0, 0, 1)
var time = 0
const TIME_PERIOD = 0.02 #

# Called when the node enters the scene tree for the first time.
func _ready():
	yousnakex.append(startx)
	yousnakey.append(starty)
	image = Image.new()
	image.create(160/4, 140/4, false, Image.FORMAT_L8)
	image.lock()
	#image.load("res://icon.png")
	for x in 160/4:
		for y in 140/4:
			board.append(0)--- Debugging process started ---
Godot Engine v3.5.stable.flathub.991bb6ac7 - https://godotengine.org
OpenGL ES 3.0 Renderer: AMD VANGOGH (DRM 3.45.0, 5.13.0-valve21.1-1-neptune-02211-gc54cda5a36f3, LLVM 12.0.1)
Async. shader compilation: OFF
 
--- Debugging process stopped ---

			image.set_pixel(x,y, blankcolor)
	image.set_pixel(foodx,foody, snakecolor)
	image.unlock()
	stop = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	time += delta
	if stop:
		return;
	get_input()
	if time < TIME_PERIOD:
		return;
	time = 0
	var oldx = yousnakex[head]
	var oldy = yousnakey[head]
	#self.get_child(0).position.x += velocity.x
	#self.get_child(0).position.y += velocity.y
	yousnakex[head] += velocity.x
	yousnakey[head] += velocity.y
	var newx = yousnakex[head] 
	var newy = yousnakey[head]
	image.lock()
	if newx == foodx && newy == foody:
		maxsize += 10
		foodx = newx+10
		foody = newy+10
		image.set_pixel(foodx,foody, Color(.5, 0, 0, 1))
	elif (!(oldx == newx && oldy == newy) && image.get_pixel(newx,newy) != Color(0, 0, 0, 1)):
		get_parent().get_child(1).visible = true
		stop = true
	if (size < maxsize):
		size+=1;
		yousnakex.append(oldx)
		yousnakey.append(oldy)
		head = (head + 1) % size
	else :
		image.set_pixel(yousnakex[tail], yousnakey[tail], Color(0, 0, 0, 1))
		head = (head + 1) % size
		tail = (tail + 1) % size

	yousnakex[head] = newx
	yousnakey[head] = newy

	if newx < 160/4 && newx >= 0 && newy < 140/4 && newy >= 0:
	   image.set_pixel(newx,newy, Color(.5, .5, .5, 1))
	else :
		get_parent().get_child(1).visible = true
		#stop = true
	image.unlock()
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	self.texture = texture
	self.get_parent().scale.x = 4
	self.get_parent().scale.y = 4
	pass

func get_input():
	# velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		if (dir != 1) && (dir != 3):
		  dir = 1
		  velocity.y = 0
		  velocity.x = 1
	if Input.is_action_pressed("ui_left"):
		if (dir != 1) && (dir != 3):
		  dir = 3
		  velocity.y = 0
		  velocity.x = -1
	if Input.is_action_pressed("ui_down"):
		if (dir != 0) && (dir != 2):
		  dir = 2
		  velocity.y = 1
		  velocity.x = 0
	if Input.is_action_pressed("ui_up"):
		if (dir != 0) && (dir != 2):
		  dir = 0
		  velocity.y = -1
		  velocity.x = 0
	#velocity = velocity.normalized() * speed

