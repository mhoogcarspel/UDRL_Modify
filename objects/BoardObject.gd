extends Node2D

class_name BoardObject

var id = 0;
var boardPosition = Vector2(0,0);
var targetPosition = Vector2(0,0);
enum TYPE {NONE = 0, ONE = 1, TWO = 2, THREE = 3, SWAP = 4}
enum OBJTYPE {Player, Wall, Token, Goal}
var objType = null;
var hidden = false;

var initDelay = 0;
var destroyQueued = false;
var destroyTimer = 0;

var shakeTimer = 0;
const shakeMax = 0.3;
const shakeMult = 15;

#stores the current state of an object.
class State:
	var id = 0;
	var boardPosition = Vector2(0,0);
	var hidden = false;
	#var objType = null;

func GetState():
	var state = State.new();
	state.id = id;
	state.boardPosition = boardPosition;
	#state.objType = objType;
	state.hidden = hidden;
	return state;

# Called when the node enters the scene tree for the first time.
func _ready():
	initDelay = rand_range(0, 0.2);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var shakeOffset = Vector2(0,0);
	if shakeTimer > 0:
		shakeTimer -= delta;
		var intensity = shakeTimer * shakeMult;
		shakeOffset = Vector2(intensity, 0);
		shakeOffset = shakeOffset.rotated(rand_range(0, 2 * PI));
	
	#lerp position to target position
	#this is framerate dependent but i've decided i don't care
	if initDelay <= 0:
		var dist = transform.origin.distance_to(targetPosition);
		var offset = transform.origin.move_toward(targetPosition, dist * 0.20) + shakeOffset;
		offset -= transform.origin;
		offset = offset.limit_length(40);
		transform.origin += offset;
	else:
		initDelay -= delta;
	
	if destroyQueued:
		destroyTimer -= delta;
		if destroyTimer <= 0:
			queue_free();

func Unload():
	targetPosition += Vector2(0, -20 * 64);
	initDelay = rand_range(0, 0.3);
	destroyQueued = true;
	destroyTimer = 2;

func SetPosition(position):
	targetPosition = position;

func SetVisible(visible):
	if visible:
		hidden = false;
		self.visible = true;
	else:
		hidden = true;
		self.visible = false;

func Shake():
	shakeTimer = shakeMax;
