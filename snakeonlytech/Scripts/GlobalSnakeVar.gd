extends Node

var width = 240
var height = 160
var tilesize = 8
var borderintiles = 1

var snakeupdatetimer = 0
var bulletupdatetimer = 0
var colmap = []

enum {NORTH, EAST, SOUTH, WEST, NODIR}

const NORTHBIT = 1
const EASTBIT = 1 << 1
const SOUTHBIT = 1 << 2
const WESTBIT = 1 << 3

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
	return ((pos.y/tilesize)*(width/tilesize)) + (pos.x/tilesize)

func initColMap():
	for h in height/8.0:
		for w in width/8.0:
			if h == height/8-1 || h ==0:
				colmap.append(1);
			elif w == width/8-1 || w ==0:
				colmap.append(1);
			else :
				colmap.append(0);


func debug_colmap():
	var dbgnode = get_tree().root.get_node("Node2D").get_node("Debug")
	for n in dbgnode.get_children():
		dbgnode.remove_child(n)
		n.queue_free()
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
			if (colmap[pos2index(pos)] == 2):
				debugpoly.color = Color(1,0,1,1)
			if (colmap[pos2index(pos)] == 1):
				debugpoly.color = Color(1,1,1,1)
			if (colmap[pos2index(pos)] == 0):
				debugpoly.color = Color(0,1,1,1)
			dbgnode.add_child(debugpoly)


