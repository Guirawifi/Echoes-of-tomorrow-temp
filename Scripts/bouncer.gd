extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	animated_sprite_2d.play("Jump")
	body.velocity.y = -800 if body.velocity.y >= 0 else body.velocity.y
	if body == player:
		player.can_dash = true


func _on_animated_sprite_2d_animation_looped():
	animated_sprite_2d.play("Still")
