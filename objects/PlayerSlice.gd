extends Sprite

const scaleNormal = 0.9;
const scaleBumped = 1.5;
const scaleRate = 0.15;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var scaleDiff = scale.x - scaleNormal;
	var newScale = scale.x - scaleDiff * scaleRate;
	scale = Vector2(newScale, newScale);

func Bump():
	scale.x = scaleBumped;
	scale.y = scaleBumped;
