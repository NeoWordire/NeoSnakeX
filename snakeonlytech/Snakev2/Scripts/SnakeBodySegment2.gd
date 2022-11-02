extends Sprite
func get_class(): return "SnakeSegment"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.name == "Head":
		var output = get_node("Segment/SegmentHitbox").connect("area_entered",get_parent(),"_head_entered_area")
		#output = get_node("NavObj/Front33Area").connect("area_entered",get_parent(),"_front33_entered_area")
		pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SegmentHitbox_area_entered(area):
	print("SSSSSSSSss")
	pass # Replace with function body.
