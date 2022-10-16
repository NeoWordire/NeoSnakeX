extends CanvasLayer
const Bullet  = preload("res://Scripts/Bullet.gd")
const Snake = preload("res://Scripts/Snake.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var moves_per_second = 1  #Times per second to move?
export (int) var bullet_moves_per_second = 1
export (Texture) var playerbodytex
export (Texture) var playerheadtex
export (Texture) var enemybodytex
export (Texture) var enemyheadtex
export (int) var numplayers = 2

export (int, "player","ai") var player1Ctrl6
var startpos = [
		Vector2(GlobalSnakeVar.tilesize,
				floor(GlobalSnakeVar.height/2/GlobalSnakeVar.tilesize)*
						GlobalSnakeVar.tilesize - GlobalSnakeVar.tilesize), 
		Vector2(GlobalSnakeVar.width - GlobalSnakeVar.tilesize *2,
				floor(GlobalSnakeVar.height/2/GlobalSnakeVar.tilesize)*
						GlobalSnakeVar.tilesize - GlobalSnakeVar.tilesize)
	]
export (Texture) var foodtex
export (int) var FoodSegments = 5
export (int) var CountDownStart = 3
export (bool) var debugging = false

var bullet
var snakes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSnakeVar.initColMap()
	bullet = Bullet.new()
	bullet.setup(Vector2(8,8),bullet_moves_per_second)
	add_child(bullet)
	var snake = Snake.new()
	snake.setup(Vector2(16,16),playerbodytex, playerheadtex)
	#snake.sprites[0].texture = playerbodytex
	add_child(snake)
	snakes.append(snake)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	GlobalSnakeVar.snakeupdatetimer += delta
	GlobalSnakeVar.bulletupdatetimer += delta
		#if (updatetime*GlobalSnakeVar.moves_per_second >= 1.0):
	if (GlobalSnakeVar.snakeupdatetimer * moves_per_second >= 1.0):
		var alive = true;
		for snake in snakes:
			if (snake.step_simulation()):
				alive = false;
		for snake in snakes:
			if alive:
				snake.update_display()
			else : 
				#GAMEOVER
				return
		GlobalSnakeVar.debug_colmap()
		#print("snaketime")
		GlobalSnakeVar.snakeupdatetimer = 0
	if (GlobalSnakeVar.bulletupdatetimer * bullet_moves_per_second >= 1.0):
		bullet.step_simulation()
		#print("bullettime")
		GlobalSnakeVar.bulletupdatetimer = 0
