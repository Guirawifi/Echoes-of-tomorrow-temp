extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const DASH_POWER = 800.0
const APPEARING_TIME = 15

var gravity = 980

@onready var sprite_2d = $Sprite2D
@onready var label = $"../Label"

var was_on_floor = false
var can_dash = false
var dashing = false

var sprite_direction = 0
var direction = 0

var coyote_timer = 0
var jump_buffering_timer = 0
var dash_timer = 0
var appearing_timer = 0

var time_to_wait = Time.get_unix_time_from_system() + 1
var frame_count = 0

func _ready():
	#--------------------------------------------------------------------------------------- DISCORD RICH PRESENCE
	DiscordRPC.details = "In the game"
	DiscordRPC.state = "So many bugs ;-;"
	DiscordRPC.refresh()

func _physics_process(delta):
	#--------------------------------------------------------------------------------------- ANIMATIONS AND SPRITE
	if appearing_timer > APPEARING_TIME:
		if (velocity.x > 1 || velocity.x < -1):
			sprite_2d.animation = "Running"
		else:
			sprite_2d.animation = "Idle"
			
		direction = Input.get_axis("left", "right")
		sprite_direction = 0
		if velocity.x < 0: sprite_direction = 1
		elif velocity.x > 0: sprite_direction = -1
		
		if sprite_direction == 1:
			sprite_2d.flip_h = true  
		elif sprite_direction == -1:
			sprite_2d.flip_h = false
	else:
		appearing_timer += 1
		
	#--------------------------------------------------------------------------------------- GRAVITY + COYOTE TIMER
	if not is_on_floor() and not dashing:
		if was_on_floor:
			was_on_floor = false
			coyote_timer = Time.get_unix_time_from_system() + 0.1
			
		if velocity.y < 0:
			gravity = 980
		else:
			gravity = 1470
			
		velocity.y += gravity * delta
		if appearing_timer > APPEARING_TIME: sprite_2d.animation = "Jumping"
		
	elif is_on_floor(): #-old BUG as dashing set was_on_floor to true and you can jump after a dash
		was_on_floor = true

	#--------------------------------------------------------------------------------------- JUMP + COYOTE JUMP + JUMP BUFFERING
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y += JUMP_VELOCITY
		if is_on_wall() and not is_on_floor():
			velocity.x = get_wall_normal()[0]*-JUMP_VELOCITY
	elif (Input.is_action_just_pressed("jump") and Time.get_unix_time_from_system() <= coyote_timer) or (Time.get_unix_time_from_system() <= jump_buffering_timer and is_on_floor()):
		velocity.y += JUMP_VELOCITY
		coyote_timer = 0
		jump_buffering_timer = 0
	if (Input.is_action_just_pressed("jump") and not is_on_floor()) or (Input.is_action_just_pressed("jump") and dashing):
		jump_buffering_timer = Time.get_unix_time_from_system() + 0.1
	if (Input.is_action_just_released("jump") and velocity.y < 0 and not dashing):
		velocity.y = 0
		
	#--------------------------------------------------------------------------------------- DASH
	if is_on_floor() and not dashing:
		can_dash = true
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		if Input.is_action_pressed("left"):
			velocity.x = -DASH_POWER
			velocity.y = 0
		if Input.is_action_pressed("right"):
			velocity.x = DASH_POWER
			velocity.y = 0
		if Input.is_action_pressed("up"):
			if abs(velocity.x) < DASH_POWER: velocity.x = 0
			velocity.y = -DASH_POWER
		if Input.is_action_pressed("down"):
			if abs(velocity.x) < DASH_POWER: velocity.x = 0
			velocity.y = DASH_POWER
		if not Input.is_action_pressed("left") and not Input.is_action_pressed("right") and not Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
			if sprite_2d.flip_h:
				velocity.x = -DASH_POWER
				velocity.y = 0
			else:
				velocity.x = DASH_POWER
				velocity.y = 0
				
		dash_timer = Time.get_unix_time_from_system() + 0.2
	
	if dashing and Time.get_unix_time_from_system() > dash_timer:
		dashing = false
		if -velocity.y > abs(JUMP_VELOCITY):
			velocity.y = JUMP_VELOCITY-1
			
	#--------------------------------------------------------------------------------------- WALKING + SLOWING DOWN
	if direction and not dashing:
		if is_on_floor():
			if (abs(velocity.x) <= SPEED):
				velocity.x = direction/abs(direction) * SPEED
			if (velocity.x/abs(velocity.x) != direction/abs(direction)):
				velocity.x += ((direction/abs(direction) * SPEED) - velocity.x)/10
		else:
			velocity.x += (direction/abs(direction) * SPEED - velocity.x)/20
	elif not direction and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 30)
	elif not dashing:
		velocity.x = move_toward(velocity.x, 0, 20)

	move_and_slide()
	
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		if body.name == "Spike":
			appearing_timer = 0
			sprite_2d.animation = "dying"
			position.x = 440
			position.y = 185
	
	#--------------------------------------------------------------------------------------- FPS COUNTER
	frame_count += 1
	
	if Time.get_unix_time_from_system() >= time_to_wait:
		time_to_wait = Time.get_unix_time_from_system() + 1
		label.text = "FPS: " + str(int(frame_count))
		frame_count = 0
