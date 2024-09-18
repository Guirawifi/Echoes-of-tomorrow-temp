extends Area2D

@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if body == player:
		player.GRAVITY = -980
		player.velocity.y = 0-player.velocity.y/20
		player.sprite_2d.flip_v = true

func _on_body_exited(body):
	if body == player:
		player.GRAVITY = 980
		player.sprite_2d.flip_v = false
