extends CharacterBody3D

class_name Player

@export_category("Speed variables")
@export var WALKING_SPEED = 5.0
@export var SPRINTING_SPEED = 8.0
@export var CROUCHING_SPEED = 3.0

@export_category("Mouse")
@export var MOUSE_SENSIBILITY = 0.4

@onready var head = $Head
@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var crouch_ray_cast = $CrouchRayCast

# states
var walking = false
var sprinting = false
var crouching = false

var current_speed = WALKING_SPEED
var lerp_speed = 10.0

const jump_velocity = 4.5

var direction = Vector3.ZERO
var input_dir = Vector2.ZERO

var crouching_depth = 0.5
var player_height = 1.8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSIBILITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSIBILITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		

func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCHING_SPEED
		head.position.y = lerp(head.position.y, player_height - crouching_depth, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		walking = false
		sprinting = false
		crouching = true
		
	elif not crouch_ray_cast.is_colliding():
		head.position.y = lerp(head.position.y, player_height, delta * lerp_speed)
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINTING_SPEED
			
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = WALKING_SPEED
			
			walking = true
			sprinting = false
			crouching = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
