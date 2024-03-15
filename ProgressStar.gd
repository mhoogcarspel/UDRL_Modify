extends Sprite


var prefabStarEffect = preload("res://objects/StarEffect.tscn");


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func SetSprite(complete):
	if complete:
		self.frame_coords.x = 1;
	else:
		self.frame_coords.x = 0;

func StarEffect():
	var obj = prefabStarEffect.instance();
	add_child(obj);
	SetSprite(true);
