extends CharacterBody2D

# i love my powers of 2
const SPEED_MAX = 128
const ACCELERATION_BASE = 64
const FRICTION_BASE = 16
const AIR_ACCEL_FRICTION = 0.25
const GRAVITY_MAX = 256
const JUMP_POWER = -256
const DASH_POWER = 64
var dash_available
var current_dash_direction
var last_floor_state

signal death # reset game

# Quick note for collision layers for you guys! Layer 1 is physical collision, layer 2 is death

func _physics_process(_delta: float) -> void:
	# forgive me children, for i have failed you in terms of efficiency
	
	# left-right movement
	var direction = Input.get_axis("LEFT", "RIGHT")
	
	# adjust acceleration, friction if you are in the air
	# i have a small feeling that this isn't optimal
	if direction: 
		if is_on_floor():
			velocity.x = move_toward(velocity.x, SPEED_MAX * direction, ACCELERATION_BASE)
		else:
			velocity.x = move_toward(velocity.x, SPEED_MAX * direction, ACCELERATION_BASE * AIR_ACCEL_FRICTION)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FRICTION_BASE)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION_BASE * AIR_ACCEL_FRICTION)
		
	# activate coyote timer
	if last_floor_state == true and not is_on_floor():
		$CoyoteTimer.start()
	
	# replenish midair jump if on floor
	if is_on_floor():
		dash_available = true
		
	# rotate wall jump raycast
	if velocity.x:
		$WallJumpRaycast.target_position.x = 15 * (velocity.x/abs(velocity.x))
	
	# activate jump
	if Input.is_action_just_pressed("JUMP"):
		$JumpBufferTimer.start()
	
	# actually do the jump
	if not $JumpBufferTimer.is_stopped():
		if is_on_floor() or not $CoyoteTimer.is_stopped():
			velocity.y = JUMP_POWER
			$JumpBufferTimer.stop()
			$CoyoteTimer.stop()
		elif $WallJumpRaycast.is_colliding():
			velocity.y = JUMP_POWER * 0.7
			velocity.x = (-256 * ($WallJumpRaycast.target_position.x/15))
			$JumpBufferTimer.stop()
	
	# Dashing: upon starting a dash, set velocity, expend dash, and keep moving in that direction while timer is active
	if Input.is_action_pressed("DASH") and dash_available:
		# dash in currently held direction
		current_dash_direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
		dash_available = false
		$DashEffectTimer.start()
		
	if !$DashEffectTimer.is_stopped():
		velocity += current_dash_direction * DASH_POWER
	
	# gravity (handled after jumps)
	if not is_on_floor():
		# Floatier jumps if you hold JUMP, fastfall if you hold DOWN
		# I initially skipped the conditional but that wouldn't be very readable.
		if Input.is_action_pressed("JUMP"):
			velocity.y = move_toward(velocity.y, GRAVITY_MAX, 10) # nooooo my beloved powers of 2
		elif Input.is_action_pressed("DOWN"):
			velocity.y = move_toward(velocity.y, GRAVITY_MAX, 32)
		else:
			velocity.y = move_toward(velocity.y, GRAVITY_MAX, 16)
	
	# animation handler
	# currently flips the animation horizontally, will add a conditional if that changes
	if velocity.x:
		$AnimatedSprite2D.scale.x = velocity.x/abs(velocity.x)
		$AnimatedSprite2D.play("walk")
	else:
		# idle animation is 1 frame atm, can be changed
		$AnimatedSprite2D.play("idle")
	
	last_floor_state = is_on_floor()
	
	# actually moves the character based on current velocity
	move_and_slide()
	
func _on_death_detect(_area):
	# Oh no you died, emit signal to tell game to reset
	death.emit()
