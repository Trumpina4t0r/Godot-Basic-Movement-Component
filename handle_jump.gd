extends Node3D

@export var jumpForce:float  = 4.5
@export var gravity: float = 9.8

@onready var root: CharacterBody3D = get_parent()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not root.is_on_floor():
		root.velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and root.is_on_floor():
		root.velocity.y = jumpForce
