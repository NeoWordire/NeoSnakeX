extends Node

const width : int = 240
const height : int = 136
const tilesize : int = 8
const borderintiles = 1

var snakeupdatetimer = 0
var bulletupdatetimer = 0
var paused = false;
var debug = false;

var colmap = []

var bullets = []
var snakes = []

var g_rng = RandomNumberGenerator.new()

var foodpoly

enum {NORTH, EAST, SOUTH, WEST, NODIR}
enum DIRS {NORTH, EAST, SOUTH, WEST, NODIR}
const NORTHBIT = 1
const EASTBIT = 1 << 1
const SOUTHBIT = 1 << 2
const WESTBIT = 1 << 3

var g_playerbodytex
var g_playerheadtex
var g_enemybodytex
var g_enemyheadtex
var g_bullet_moves_per_second
var g_snake_moves_per_second
var g_numplayers
var g_shoot_cooldown
var g_FoodSegments
var g_CountDownStart
var g_debugging
#var g_startpos
#var g_startrot
#var g_player1Ctrl
var g_foodsegments

var g_time_between_snake = 0
var g_time_between_bullet = 0
var g_time_between_input = 0
var g_counterlastsnake = 0

func posdir2pos(pos, newdir):
	if (newdir == NORTH):
		pos.y -= 1 * tilesize
	if (newdir == EAST):
		pos.x += 1 * tilesize
	if (newdir == SOUTH):
		pos.y += 1 * tilesize
	if (newdir == WEST):
		pos.x -= 1 * tilesize
	return pos

func pos2index(pos):
	if (pos.x < 0 || pos.x >= width || pos.y < 0 || pos.y >= height):
		return -1
	return ((floor(pos.y)/tilesize)*(floor(width)/tilesize)) + (floor(pos.x)/tilesize)

func initColMap():
	colmap = []
	for h in height/tilesize:
		for w in width/tilesize:
			if h == height/tilesize-1 || h ==0:
				colmap.append(1);
			elif w == width/8-1 || w ==0:
				colmap.append(1);
			else :
				colmap.append(0);

var debugcolmapnodes = []

func debug_colmap():
	var dbgnode = get_tree().root.get_node("Node2D").get_node("Debug")
	if (debugcolmapnodes.size() != 0):
		for node in debugcolmapnodes:
			if (colmap[pos2index(node.position)] == 2):
				node.color = Color(1,0,1,1)
			if (colmap[pos2index(node.position)] == 1):
				node.color = Color(1,1,1,1)
			if (colmap[pos2index(node.position)] == 0):
				node.color = Color(0,1,1,1)
			#dbgnode.remove_child(n)
			#n.queue_free()
	else:
		for h in height/tilesize:
			for w in width/tilesize:
				var pos = Vector2(w*tilesize,h*tilesize)
				var debugpoly = Polygon2D.new()
				debugpoly.polygon = PoolVector2Array([
					Vector2(0,0),
					Vector2(0,tilesize),
					Vector2(tilesize,tilesize),
					Vector2(tilesize,0)])
				debugpoly.position = pos
				debugcolmapnodes.append(debugpoly)
				dbgnode.add_child(debugpoly)


