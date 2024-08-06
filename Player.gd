extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 980
@onready var sprite_2d = $Sprite2D
var was_on_floor = false
var coyote_time = 9999999999.99

func _ready():
	DiscordRPC.details = "In the game"
	DiscordRPC.state = "So many bugs ;-;"
	
	DiscordRPC.refresh()

func _physics_process(delta):
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "Running"
	else:
		sprite_2d.animation = "Idle"
		
	# Add the gravity.
	if not is_on_floor():
		if was_on_floor:
			was_on_floor = false
			coyote_time = Time.get_unix_time_from_system() + 0.1
			
		if velocity.y < 0:
			gravity = 980
		else:
			gravity = 1300
		velocity.y += gravity * delta
		sprite_2d.animation = "Jumping"
	else:
		was_on_floor = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and Time.get_unix_time_from_system() <= coyote_time:
		velocity.y = JUMP_VELOCITY
	if (Input.is_action_just_released("jump") and velocity.y < 0):
		velocity.y = 0
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 30)

	move_and_slide()
	
	var isLeft = velocity.x < 0
	var isRight = velocity.x > 0
	if isLeft:
		direction = 1
	elif isRight:
		direction = -1
	
	if direction == 1:
		sprite_2d.flip_h = isLeft  
	elif direction == -1:
		sprite_2d.flip_h = not isRight
