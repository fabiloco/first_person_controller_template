extends Node

class_name PlayerHeadBobbing

@export var player: Player
@export var eyes: Node3D

@export_category("Bobbing speed")
@export var sprinting_speed = 22.0
@export var walking_speed = 14.0
@export var crouching_speed = 10.0

@export_category("Bobbing intensity")
@export var sprinting_intensity = 0.2
@export var walking_intensity = 0.1
@export var crouching_intensity = 0.05

var vector = Vector2.ZERO
var index = 0.0
var current_intensity = 0.0

func _process(delta):
	if player.sprinting:
		current_intensity = sprinting_intensity
		index += sprinting_speed * delta
	elif player.crouching:
		current_intensity = crouching_intensity
		index += crouching_speed * delta
	elif player.walking:
		current_intensity = crouching_intensity
		index += walking_speed * delta
		
	if player.is_on_floor() && player.input_dir != Vector2.ZERO:
		vector.y = sin(index)
		vector.x = sin(index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, vector.y * (current_intensity / 2.0), delta * player.lerp_speed)
		eyes.position.x = lerp(eyes.position.x, vector.x * (current_intensity), delta * player.lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * player.lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * player.lerp_speed)
