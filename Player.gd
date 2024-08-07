extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 980
@onready var sprite_2d = $Sprite2D
var was_on_floor = false
var coyote_time = 0.0
var jump_buffering = 0.0
var dashing = 0
var dash_power = 800.0
var dash_timer = 0
var can_dash = false

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
	if not is_on_floor() and not dashing:
		if was_on_floor:
			was_on_floor = false
			coyote_time = Time.get_unix_time_from_system() + 0.1
			
		if velocity.y < 0:
			gravity = 980
		else:
			gravity = 1470
		velocity.y += gravity * delta
		sprite_2d.animation = "Jumping"
	else:
		was_on_floor = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif (Input.is_action_just_pressed("jump") and Time.get_unix_time_from_system() <= coyote_time) or (Time.get_unix_time_from_system() <= jump_buffering and is_on_floor()):
		velocity.y = JUMP_VELOCITY
		coyote_time = 0
		jump_buffering = 0
	if (Input.is_action_just_pressed("jump") and not is_on_floor()) or (Input.is_action_just_pressed("jump") and dashing):
		jump_buffering = Time.get_unix_time_from_system() + 0.1
	if (Input.is_action_just_released("jump") and velocity.y < 0 and not dashing):
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	var isLeft = velocity.x < 0
	var isRight = velocity.x > 0
	var sprite_direction = 0
	
	if isLeft:
		sprite_direction = 1
	elif isRight:
		sprite_direction = -1
		
	if sprite_direction == 1:
		sprite_2d.flip_h = isLeft  
	elif sprite_direction == -1:
		sprite_2d.flip_h = not isRight
	
	if is_on_floor() and not dashing:
		can_dash = true
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		if Input.is_action_pressed("left"):
			velocity.x = -dash_power
			velocity.y = 0
		if Input.is_action_pressed("right"):
			velocity.x = dash_power
			velocity.y = 0
		if Input.is_action_pressed("up"):
			if abs(velocity.x) < dash_power: velocity.x = 0
			velocity.y = -dash_power
		if Input.is_action_pressed("down"):
			if abs(velocity.x) < dash_power: velocity.x = 0
			velocity.y = dash_power
		dash_timer = Time.get_unix_time_from_system() + 0.2
	
	if dashing and Time.get_unix_time_from_system() > dash_timer:
		dashing = false
		velocity.y = 0
	
	if direction and not dashing:
		if (abs(velocity.x) <= SPEED):
			velocity.x = direction * SPEED
		if (velocity.x/abs(velocity.x) != direction/abs(direction)):
			velocity.x += (direction * SPEED) - abs(velocity.x)/10
	elif not dashing:
		velocity.x = move_toward(velocity.x, 0, 20)

	move_and_slide()
