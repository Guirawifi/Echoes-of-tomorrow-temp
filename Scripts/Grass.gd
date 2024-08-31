extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var number = RandomNumberGenerator.new().randi_range(1, 3)
	if number == 1:
		play("1")
	if number == 2:
		play("2")
	if number == 3:
		play("3")
	frame = RandomNumberGenerator.new().randi_range(0, 6)
	
	print(animation, "     ", frame)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
