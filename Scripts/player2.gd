extends CharacterBody2D

#------------------------------------------------------------------------------- CONST
const SPEED = 300.0
var JUMP_VELOCITY = -550.0
var WALL_JUMP_VELOCITY = -500.0
var GRAVITY = 980
const APPEARING_TIME = 15
const DISAPPEARING_TIME = 15
const DASH_VELOCITY = 980

#------------------------------------------------------------------------------- STATES OF PLAYER
var appearing = true
var dying = false
var was_on_floor = false
var dashing = false
var can_dash = false
var can_coyote = false
var jumping = false

#------------------------------------------------------------------------------- OBJECTS IN SCENE
@onready var sprite_2d = $Sprite2D
@onready var label = $"../Label"
@onready var character_body_2d = $"."
@onready var collision_1 = $CollisionShape2D
@onready var collision_2 = $CollisionShape2D2
@onready var player = $"."

#------------------------------------------------------------------------------- SPRITE DIRECTION
var sprite_direction = 0
var direction = 0

#------------------------------------------------------------------------------- TIMERS
var coyote_timer = 0
var jump_buffering_timer = 0
var dash_timer = 0
var spawning_timer = 0
var was_in_reverse_gravity = 0

#------------------------------------------------------------------------------- FPS COUNTER
var frame_count = 0
var next_update = Time.get_unix_time_from_system() + 1

func _ready():
	#----------------------------------------------------------------------------------------------- DISCORD RICH PRESENCE
#	DiscordRPC.details = "In the game"
#	DiscordRPC.state = "So many bugs ;-;"
#	DiscordRPC.refresh()
	return
	
func _physics_process(delta):
	if not appearing and not dying:
		direction = Input.get_axis("left", "right")
		
		sprite_direction = 0
		if velocity.x < 0: sprite_direction = 1
		elif velocity.x > 0: sprite_direction = -1
			
		if GRAVITY/abs(GRAVITY) == -1:
			JUMP_VELOCITY = 550.0
			WALL_JUMP_VELOCITY = 500.0
			if sprite_direction == 1:
				sprite_2d.flip_h = false
			elif sprite_direction == -1:
				sprite_2d.flip_h = true
		else:
			JUMP_VELOCITY = -550.0
			WALL_JUMP_VELOCITY = -500.0
			if sprite_direction == 1:
				sprite_2d.flip_h = true
			elif sprite_direction == -1:
				sprite_2d.flip_h = false
		if is_on_floor() and GRAVITY/abs(GRAVITY) == 1 or is_on_ceiling() and GRAVITY/abs(GRAVITY) == -1: #------------------------------------------------------------------------- ALL ON FLOOR
			was_on_floor = true
			jumping = false
			can_coyote = true
			
			#------------------------------------------------------------------- ANIMATIONS + SPRITE
			if (velocity.x > 1 || velocity.x < -1):
				sprite_2d.animation = "Running"
			else:
				sprite_2d.animation = "Idle"
				
			#------------------------------------------------------------------- JUMP
			if Input.is_action_just_pressed("jump"):
				if is_on_floor() and GRAVITY/abs(GRAVITY) == 1 or is_on_ceiling() and GRAVITY/abs(GRAVITY) == -1:
					velocity.y += JUMP_VELOCITY
					jumping = true
					
				#------------------------------------------------------------------- JUMP BUFFERING
			elif Time.get_unix_time_from_system() <= jump_buffering_timer:
				velocity.y += JUMP_VELOCITY
				jumping = true
				jump_buffering_timer = 0
					
			#--------------------------------------------------------------------------------------- ALL ON FLOOR NOT DASH
			if not dashing:
				
				#--------------------------------------------------------------- REGISTER IF WE CAN DASH
				can_dash = true
				
				#--------------------------------------------------------------- MOVING AND FRICTION
				if direction:
					if (abs(velocity.x) <= SPEED):
						velocity.x = direction/abs(direction) * SPEED
					if (velocity.x/abs(velocity.x) != direction/abs(direction)):
						velocity.x += ((direction/abs(direction) * SPEED) - velocity.x)/10
				else:
					velocity.x = move_toward(velocity.x, 0, 30)
			else:
				velocity.x = move_toward(velocity.x, 0, 20)
				
		else: #------------------------------------------------------------------------------------- ALL IN AIR
			#------------------------------------------------------------------- JUMP BUFFERING TIMER
			if Input.is_action_just_pressed("jump"):
				jump_buffering_timer = Time.get_unix_time_from_system() + 0.1
				
				#----------------------------------------------------------------------- COYOTE JUMP
				if Time.get_unix_time_from_system() <= coyote_timer and can_coyote:
					coyote_timer = 0
					velocity.y += JUMP_VELOCITY
					jumping = true
				
				#--------------------------------------------------------------- WALL JUMP
				if is_on_wall():
					velocity.x = get_wall_normal()[0]*-JUMP_VELOCITY/1.5
					if velocity.y < WALL_JUMP_VELOCITY:
						velocity.y += WALL_JUMP_VELOCITY
					else:
						velocity.y = WALL_JUMP_VELOCITY
				
			#------------------------------------------------------------------- ANIMATION IN THE AIR
			sprite_2d.animation = "Jumping"
			
			#-------------------------------------------------------------------------------------- ALL IN AIR NOT DASH
			if not dashing:
				#--------------------------------------------------------------- CONTROL HEIGHT OF JUMP
				if velocity.y < 0 and Input.is_action_just_released("jump") and jumping:
					velocity.y = 0
					jumping = false
					can_coyote = false
				
				#--------------------------------------------------------------- COYOTE SET TIMER
				if was_on_floor:
					was_on_floor = false
					coyote_timer = Time.get_unix_time_from_system() + 0.15
					
				#--------------------------------------------------------------- APPLY GRAVITY
				if velocity.y < 0:
					velocity.y += ((float(GRAVITY)/100) * 150) * delta
				else:
					velocity.y += GRAVITY * delta
					jumping = false
				
				#--------------------------------------------------------------- MOVING
				if direction:
					velocity.x += (direction/abs(direction) * SPEED - velocity.x)/20
		
		#----------------------------------------------------------------------- DASH
		if Input.is_action_just_pressed("dash"):
			var dash_direction = Vector2(direction, Input.get_axis("down", "up"))
			dash_direction = dash_direction/abs(dash_direction+Vector2(0.000000001, 0.000000001))
			print(dash_direction)
			
			velocity.y = DASH_VELOCITY * -dash_direction.y
			
			can_dash = false
		
		move_and_slide()
		
	elif appearing:
		spawning_timer += 1
		sprite_2d.offset = Vector2(-48, -48)
		if spawning_timer > APPEARING_TIME:
			appearing = false
			dying = false
			spawning_timer = 0
			sprite_2d.animation = "Jumping"
			sprite_2d.offset = Vector2(-17, -22)
	
	elif dying:
		spawning_timer += 1
		if spawning_timer > DISAPPEARING_TIME:
			position.x = 500
			position.y = 170
			velocity.x = 0
			velocity.y = 0
			dying = false
			appearing = true
			sprite_2d.animation = "Appearing"
			spawning_timer = 0
		else:
			sprite_2d.animation = "Dying"
			sprite_2d.offset = Vector2(-48, -48)
		
	#----------------------------------------------------------------------------------------------- DYING
#	if (not dying) and (not appearing):
#		for index in get_slide_collision_count():
#			var collision := get_slide_collision(index)
#			var body := collision.get_collider()
#			if body.name == "Spike":
#				dying = true
#				print("Spike")
#				break

	if Input.is_action_just_pressed("die"):
		dying = true
		
	if Input.is_action_just_pressed("flip"):
		GRAVITY = -GRAVITY
		velocity.y = 0-velocity.y/20
		rotate(PI)
				
#--------------------------------------------------------------------------------------- FPS COUNTER
	frame_count += 1
	if Time.get_unix_time_from_system() >= next_update:
		next_update = Time.get_unix_time_from_system() + 1
		label.text = "FPS: " + str(int(frame_count))
		frame_count = 0
		
	if GRAVITY/abs(GRAVITY) == -1:
		was_in_reverse_gravity = Time.get_unix_time_from_system()
