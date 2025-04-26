extends CharacterBody2D

const MAX_SPEED = 100
const JUMP_VELOCITY = 400.0
const GRAVITY = 900.0

var last_direction := Vector2.RIGHT
var gravity_direction := 1 # 1 = normal, -1 = flipped
var can_flip := true
var flipped_this_frame := false

var FLOOR_NORMAL = Vector2.UP  # <- New!

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")

	# Horizontal movement
	velocity.x = direction.x * MAX_SPEED

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta * gravity_direction
	else:
		velocity.y = 0.0

	# Gravity flip input
	if Input.is_action_just_pressed("Flip") and can_flip and is_on_floor():
		flip_gravity()

	# Jumping
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = -JUMP_VELOCITY * gravity_direction
		play_jump_animation(last_direction)

	# Move the character
	move_and_slide()  # <--- we will fix floor detection below!

	# Update correct floor detection
	set_up_direction(FLOOR_NORMAL)

	# Landing detection
	if is_on_floor() and not flipped_this_frame:
		can_flip = true

	flipped_this_frame = false

	# Animation handling
	if is_on_floor():
		if direction.x != 0:
			play_walk_animation(direction)
		else:
			play_idle_animation(last_direction)
	else:
		if direction.x != 0:
			play_jump_animation(direction)

	if direction.x != 0:
		last_direction = Vector2(direction.x, 0)

func flip_gravity():
	gravity_direction *= -1
	scale.y *= -1
	can_flip = false
	flipped_this_frame = true
	FLOOR_NORMAL = Vector2.UP * gravity_direction  # <- Important!!
	print("Gravity flipped! New floor normal:", FLOOR_NORMAL)

# Walk animation
func play_walk_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("Walk_Right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("Walk_Left")

# Idle animation
func play_idle_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("Idle_Right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("Idle_Left")

# Jump animation
func play_jump_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("Jump_Right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("Jump_Left")
	else:
		if last_direction.x > 0:
			$AnimatedSprite2D.play("Jump_Right")
		else:
			$AnimatedSprite2D.play("Jump_Left")
