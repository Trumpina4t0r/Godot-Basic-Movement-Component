extends Node3D

#Attach this script on a Node3D directly attach to the root Node normally a CharacterBody3D

##assign the Camera3D here
@export var camera: Camera3D

##This variable controls the player's movement speed.
@export var speed : float = 5.0
##if this is equal to the speed it will stop automatically
@export var slowDownSpeed: float = 2
##smoothness of the rotation higher value will snap to direction using keyboard
@export var rotationRate: float = 5
##if this is checked the camera will always be behind the character
@export var UseRotationYaw: bool

#keep a reference of the root node 
var root: CharacterBody3D

func _ready() -> void:
	root = get_parent()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("MoveA", "MoveD", "MoveW", "MoveS")
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0  # Flatten Y to prevent tilting

	if direction.length() > 0:
		#if direction is more than 0 make the character move
		direction = direction.normalized()
		root.velocity.x = direction.x * speed
		root.velocity.z = direction.z * speed
		
	else:
		#slow down the character
		root.velocity.x = move_toward(root.velocity.x, 0, slowDownSpeed)
		root.velocity.z = move_toward(root.velocity.z, 0, slowDownSpeed)
		
	root.move_and_slide()
	
	if UseRotationYaw:
		#will always face away from the camera
		rotate_away_from_camera(delta) 
	#will always rotate toward the input_dir
	else:turnTo(direction,delta)




#Smoothly rotates the character (root) to face the given direction.
#It calculates the target yaw (rotation around the Y-axis) based on the input direction.
#Then it interpolates (lerp_angle) between the current and target yaw using delta and rotationRate.
#this creates a smooth turning effect toward the movement direction.
func turnTo(direction: Vector3,delta) -> void:
	if direction.length() > 0:
		direction = direction.normalized()
		var target_yaw = atan2(-direction.x, -direction.z)
		var current_yaw = root.rotation.y
		var new_yaw = lerp_angle(current_yaw, target_yaw, delta * rotationRate)

		root.rotation.y = new_yaw




#Smoothly rotates the character (root) to face away from the camera.
#Gets the camera's forward direction and flattens it to the ground plane.
#Reverses it to get the direction opposite of the camera.
#Calculates the yaw (horizontal rotation) needed to face that direction.
#Uses lerp_angle to smoothly rotate the character to that target direction over time.
func rotate_away_from_camera(delta: float) -> void:
	var camera_forward = camera.global_transform.basis.z
	camera_forward.y = 0  # Flatten to avoid looking up/down
	camera_forward = camera_forward.normalized()
	
	# Target direction is opposite of camera's forward
	var target_direction = -camera_forward
	
	# Compute target yaw
	var target_yaw = atan2(-target_direction.x, -target_direction.z)
	var current_yaw = root.rotation.y
	var new_yaw = lerp_angle(current_yaw, target_yaw, delta * rotationRate)

	root.rotation.y = new_yaw
