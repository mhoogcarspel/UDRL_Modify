extends BoardObject

var type = TYPE.ONE;
var t =  0;

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	objType = OBJTYPE.Token;
	SetSprite();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta;
	
	$Sprite.offset.y = (sin(t) * 4);
	$Shadow.offset.x = (sin(t) * -4) + 8;
	pass

func SetSprite():
	if type == TYPE.NONE:
		$Sprite.frame_coords = Vector2(0, 0);
	if type == TYPE.ONE:
		$Sprite.frame_coords = Vector2(1, 0);
	if type == TYPE.TWO:
		$Sprite.frame_coords = Vector2(2, 0);
	if type == TYPE.THREE:
		$Sprite.frame_coords = Vector2(3, 0);
	if type == TYPE.SWAP:
		$Sprite.frame_coords = Vector2(4, 0);
	pass
