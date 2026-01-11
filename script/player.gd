extends CharacterBody2D

# i love my powers of 2
const SPEED_MAX = 128
const ACCELERATION_BASE = 64
const FRICTION_BASE = 32
const GRAVITY_MAX = 512
const JUMP_POWER = 256
var jump_state

func _physics_process(_delta: float) -> void:
	# left-right movement
	var direction = Input.get_axis("LEFT", "RIGHT")
	
	if direction: 
		velocity.x = move_toward(velocity.x, SPEED_MAX * direction, ACCELERATION_BASE)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION_BASE)
	
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y -= JUMP_POWER
	
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, GRAVITY_MAX, 16)
	
	# animation handler
	# currently flips the animation horizontally, will add a conditional if that changes
	
	if velocity.x:
		$AnimatedSprite2D.scale.x = velocity.x/abs(velocity.x)
		$AnimatedSprite2D.play("walk")
	else:
		# idle animation is 1 frame atm, can be changed
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()
