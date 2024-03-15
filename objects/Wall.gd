extends BoardObject

class_name Wall

const tilesetMap = {
	"0000": Vector2(0,0),
	"0001": Vector2(1,0),
	"0010": Vector2(3,0),
	"0011": Vector2(2,0),
	"0100": Vector2(0,1),
	"0101": Vector2(1,1),
	"0110": Vector2(3,1),
	"0111": Vector2(2,1),
	"1000": Vector2(0,3),
	"1001": Vector2(1,3),
	"1010": Vector2(3,3),
	"1011": Vector2(2,3),
	"1100": Vector2(0,2),
	"1101": Vector2(1,2),
	"1110": Vector2(3,2),
	"1111": Vector2(2,2),
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	objType = OBJTYPE.Wall;

func SetSprite():
	#tileset stuff
	var tilestring = "0000"
	#get neighbors
	var up    = get_parent().FindObjAt(boardPosition + Vector2( 0,-1));
	var down  = get_parent().FindObjAt(boardPosition + Vector2( 0, 1));
	var left  = get_parent().FindObjAt(boardPosition + Vector2(-1, 0));
	var right = get_parent().FindObjAt(boardPosition + Vector2( 1, 0));
	
	if up != null:
		if up.objType == BoardObject.OBJTYPE.Wall and !up.hidden:
			tilestring[0] = "1";
	if down != null:
		if down.objType == BoardObject.OBJTYPE.Wall and !down.hidden:
			tilestring[1] = "1";
	if left != null:
		if left.objType == BoardObject.OBJTYPE.Wall and !left.hidden:
			tilestring[2] = "1";
	if right != null:
		if right.objType == BoardObject.OBJTYPE.Wall and !right.hidden:
			tilestring[3] = "1";
	
	if tilesetMap.has(tilestring):
		self.frame_coords = tilesetMap[tilestring];
