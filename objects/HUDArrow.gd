extends Node2D

const scaleNormal = 0.9;
const scaleBumped = 1.5;
const scaleRate = 0.15;

var currentState = BoardObject.TYPE.NONE;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Token.rotation = -self.rotation;
	pass # Replace with function body.

func SetState(state):
	$Token.frame_coords.x = state;
	$Bkg.frame_coords.x = state;
	
	if state != currentState:
		currentState = state;
		Bump();

func _process(delta):
	var scaleDiff = $Token.scale.x - scaleNormal;
	var newScale = $Token.scale.x - scaleDiff * scaleRate;
	$Token.scale = Vector2(newScale, newScale);

func Bump():
	$Token.scale.x = scaleBumped;
	$Token.scale.y = scaleBumped;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
