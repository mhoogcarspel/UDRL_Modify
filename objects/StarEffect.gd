extends Sprite

const rateScale = 1.3;
const rateAlpha = 0.7;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var newScale = self.scale.x + (rateScale * delta);
	self.scale = Vector2(newScale, newScale);
	
	self.modulate.a -= rateAlpha * delta;
	
	if self.modulate.a <= 0:
		queue_free();
