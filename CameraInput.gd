extends Node3D
#components ref
@export var springArm: SpringArm3D
@export var camera: Camera3D

##this will overide the value from the SpringArm3D
@export var springArmLenght:float = 10
##when looking Down Max Angle value
@export var lookDownMaxAngle:float = -70
##when looking Up Max Angle value
@export var lookUpMaxAngle: float = 50

##Controller sensitivity do not affect mouse
@export var controllerSensibility: float = 200
##Mouse sensitivity do not affect controller
@export var mouseSensibility: float = 0.1

@export var reverseXaxis: bool = true
@export var reverseYaxis: bool = true

@onready var root: CharacterBody3D = get_parent()
@onready var springArmHeight: float = springArm.position.y

var input_mode_initialized: bool = false
var last_input_was_controller := false
var controller_detected_once := false
var mouse_detected_once := false
var mouse_input: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.position.z = springArmLenght
	springArm.spring_length = camera.position.z
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleController(delta)
	handleMouse(delta)


func handleController(delta)->void:
	var look_input:= Input.get_vector("viewRight","viewLeft","viewDown","viewUp")
	look_input = controllerSensibility * look_input * delta
	Rotation(look_input)

		

func handleMouse(delta)->void:
	var look_input: Vector2
	look_input += mouse_input
	mouse_input = Vector2.ZERO
	Rotation(look_input)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = event.relative * mouseSensibility
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if not last_input_was_controller or not input_mode_initialized:
			last_input_was_controller = true
			input_mode_initialized = true
			reverseXaxis = !reverseXaxis
			reverseYaxis = !reverseYaxis

	elif event is InputEventKey or event is InputEventMouse:
		if last_input_was_controller or not input_mode_initialized:
			last_input_was_controller = false
			input_mode_initialized = true
			reverseXaxis = !reverseXaxis
			reverseYaxis = !reverseYaxis





func Rotation(look_input)->void:
	if reverseYaxis:
		springArm.rotation_degrees.x += look_input.y * -1
	else: springArm.rotation_degrees.x += look_input.y
	
	if(reverseXaxis):
		springArm.rotation_degrees.y += look_input.x * -1
	else: springArm.rotation_degrees.y += look_input.x
	
	springArm.rotation_degrees.x = clamp(springArm.rotation_degrees.x, lookDownMaxAngle,lookUpMaxAngle)

func _physics_process(delta: float) -> void:
	springArm.position = root.position + Vector3(0,springArmHeight,0)
