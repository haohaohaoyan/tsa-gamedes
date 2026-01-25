#extends CharacterBody2D
#
## i love my powers of 2
#const SPEED_MAX = 128
#const ACCELERATION_BASE = 64
#const FRICTION_BASE = 32
#const GRAVITY_MAX = 512
#const JUMP_POWER = 256
#var jump_state
#
#func _physics_process(_delta: float) -> void:
	## left-right movement
	#var direction = Input.get_axis("LEFT", "RIGHT")
	#
	#if direction: 
		#velocity.x = move_toward(velocity.x, SPEED_MAX * direction, ACCELERATION_BASE)
	#else:
		#velocity.x = move_toward(velocity.x, 0, FRICTION_BASE)
	#
	#if Input.is_action_just_pressed("JUMP") and is_on_floor():
		#velocity.y -= JUMP_POWER
	#
	#if not is_on_floor():
		#velocity.y = move_toward(velocity.y, GRAVITY_MAX, 16)
	#
	## animation handler
	## currently flips the animation horizontally, will add a conditional if that changes
	#
	#if velocity.x:
		#$AnimatedSprite2D.scale.x = velocity.x/abs(velocity.x)
		#$AnimatedSprite2D.play("walk")
	#else:
		## idle animation is 1 frame atm, can be changed
		#$AnimatedSprite2D.play("idle")
	#
	#move_and_slide()
	
extends CharacterBody2D


const SPEED_MAX = 128
const ACCELERATION_BASE = 64
const FRICTION_BASE = 32


const GRAVITY_MAX = 512
const JUMP_POWER = 256
const DOUBLE_JUMP_POWER = 384

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS


const DASH_SPEED = 400
const DASH_TIME = 0.15
const DASH_COOLDOWN = 0.5

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0


func _ready():
	jumps_left = MAX_JUMPS


func _physics_process(delta: float) -> void:

	
	if is_on_floor():
		jumps_left = MAX_JUMPS

	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	
	if Input.is_action_just_pressed("DASH") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_COOLDOWN
	if Input.is_action_just_pressed("DASH"):
		print("DASH INPUT DETECTED")
	
	if is_dashing:
		var dash_direction = sign(velocity.x)
		if dash_direction == 0:
			dash_direction = $AnimatedSprite2D.scale.x

		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0

		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	else:
		
		var direction = Input.get_axis("LEFT", "RIGHT")

		if direction:
			velocity.x = move_toward(
				velocity.x,
				SPEED_MAX * direction,
				ACCELERATION_BASE
			)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION_BASE)

		
		if Input.is_action_just_pressed("JUMP") and jumps_left > 0:
			if jumps_left == 1:
				velocity.y = -DOUBLE_JUMP_POWER
			else:
				velocity.y = -JUMP_POWER

			jumps_left -= 1

		
		if not is_on_floor():
			velocity.y = move_toward(velocity.y, GRAVITY_MAX, 16)

	
	if velocity.x != 0:
		$AnimatedSprite2D.scale.x = velocity.x / abs(velocity.x)
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
