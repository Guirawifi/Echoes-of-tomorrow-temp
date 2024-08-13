extends AnimatableBody2D

@onready var player_detection = $PlayerDetection
@onready var player_detection_2 = $PlayerDetection2

var fall = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_detection.get_collider() or player_detection_2.get_collider():
		fall = true
	if fall:
		move_and_collide(Vector2(0, 10))
