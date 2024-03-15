extends BoardObject

var typeUp = TYPE.NONE;
var typeDown = TYPE.NONE;
var typeLeft = TYPE.NONE;
var typeRight = TYPE.NONE;

var t = 0;

class_name Player

class StatePlayer extends BoardObject.State:
	var typeUp = BoardObject.TYPE.NONE;
	var typeDown = BoardObject.TYPE.NONE;
	var typeLeft = BoardObject.TYPE.NONE;
	var typeRight = BoardObject.TYPE.NONE;

func GetState():
	var state = StatePlayer.new();
	state.id = id;
	state.boardPosition = boardPosition;
	#state.objType = objType;
	state.hidden = hidden;
	state.typeUp = typeUp;
	state.typeDown = typeDown;
	state.typeLeft = typeLeft;
	state.typeRight = typeRight;
	return state;

# Called when the node enters the scene tree for the first time.
func _ready():
	objType = OBJTYPE.Player;
	SetSprite();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta;
	
	#pulsate swap ring
	var swapringscale = (sin(t) * 0.1) + 1;
	$SwapRing.scale = Vector2(swapringscale, swapringscale);

func SetSprite():
	$Up.frame_coords.x = typeUp;
	$Down.frame_coords.x = typeDown;
	$Left.frame_coords.x = typeLeft;
	$Right.frame_coords.x = typeRight;
	
	if typeUp == BoardObject.TYPE.SWAP or typeDown == BoardObject.TYPE.SWAP or typeLeft == BoardObject.TYPE.SWAP or typeRight == BoardObject.TYPE.SWAP:
		$SwapRing.visible = true;
	else:
		$SwapRing.visible = false;
	
	var root = get_tree().get_root().get_node("Root");
	root.get_node("Up").SetState(typeUp);
	root.get_node("Down").SetState(typeDown);
	root.get_node("Left").SetState(typeLeft);
	root.get_node("Right").SetState(typeRight);

func Bump(slice):
	if slice == 0:
		$Up.Bump();
	elif slice == 1:
		$Down.Bump();
	elif slice == 2:
		$Left.Bump();
	else:
		$Right.Bump();
