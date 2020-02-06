extends KinematicBody

export var speed = 5.4
export var acceleration = 7
export var gravity = -9.8 * 5
export var jump_power = 20
export var mouse_sensitivity = 0.1

onready var head = $Head
onready var camera = $Head/Camera
onready var raycast = $FloorRayCast

var has_contact = false

var velocity = Vector3()
var camera_x_rotation = 0

const MAX_SLOPE_ANGLE = 50
const MAX_STAIR_SLOPE = 20
const STAIR_JUMP_HEIGHT = 6

var target
var can_move = true
var can_interact = false
var basis_buffer
var camera_basis
var current_camera_area = null
var default_camera

func _ready():
	#Global.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	basis_buffer = true
	camera_basis = get_viewport().get_camera().get_global_transform().basis
	print(get_viewport().get_camera().get_parent().get_name())

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		$GroundCollision.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90:
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
	
	if (can_interact and event.is_action_pressed("interact")):
		var dialogue_parser = get_node("../DialogueParser")
		dialogue_parser.init_dialogue(target.get_name())
		can_move = false
		dialogue_parser.target = target.get_name()
		can_interact = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("ui_accept"):
		OS.window_fullscreen = !OS.window_fullscreen
	#$"Head/Camera".current = true

func _physics_process(delta):
	if (can_move):
		move(delta)
	else:
		velocity.x = 0
		velocity.z = 0

func move(delta):
	#var head_basis = head.get_global_transform().basis
	#camera_basis = $"../Camera".get_global_transform().basis
	#camera_basis = Global.current_camera.get_global_transform().basis
	#camera_basis = get_viewport().get_camera().get_global_transform().basis
	if (Input.is_action_just_released("move_backward") or Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right")):
		camera_basis = get_viewport().get_camera().get_global_transform().basis
		#camera_basis = Global.current_camera.get_global_transform().basis
		basis_buffer = false
	else:
		if (Global.current_camera == $"Head/Camera"):
			camera_basis = get_viewport().get_camera().get_global_transform().basis
		if (Global.previous_camera != null and basis_buffer == true):
			if (camera_basis != Global.previous_camera.get_global_transform().basis):
				Global.previous_camera.get_global_transform().basis
		#camera_basis = get_viewport().get_camera().get_global_transform().basis
	
	var direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		#direction -= head_basis.z
		direction -= camera_basis.z
	elif Input.is_action_pressed("move_backward"):
		#direction += head_basis.z
		direction += camera_basis.z
	
	if Input.is_action_pressed("move_left"):
		#direction -= head_basis.x
		direction -= camera_basis.x
	elif Input.is_action_pressed("move_right"):
		#direction += head_basis.x
		direction += camera_basis.x
	
	direction.y = 0
	direction = direction.normalized()
	
	if is_on_floor():
		has_contact = true
		var n = raycast.get_collision_normal()
		var floor_angle = rad2deg(acos(n.dot(Vector3(0, 1, 0))))
		if floor_angle > MAX_SLOPE_ANGLE:
			velocity.y += gravity * delta
	else:
		if !raycast.is_colliding():
			has_contact = false
		velocity.y += gravity * delta
	
	if has_contact and !is_on_floor():
		move_and_collide(Vector3(0, -1, 0))
	
	if (direction.length() > 0 and $StairsRayCast.is_colliding()):
		var stair_normal = $StairsRayCast.get_collision_normal()
		var stair_angle = rad2deg(acos(stair_normal.dot(Vector3(0, 1, 0))))
		if (stair_angle < MAX_STAIR_SLOPE):
			#velocity.y = STAIR_JUMP_HEIGHT
			velocity = Vector3(direction.x * 4, STAIR_JUMP_HEIGHT, direction.z * 4)
			has_contact = false
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	if Input.is_action_just_pressed("jump") and has_contact:
		velocity.y = jump_power
		has_contact = false
	
	move_and_slide(velocity, Vector3(0, 1, 0))
	
	$StairsRayCast.translation.x = direction.x
	$StairsRayCast.translation.z = direction.z
	#$StairsRayCast.cast_to = Vector3(direction.x/2, -0.6, direction.z/2)

func _on_Door_body_entered(body):
	if(body == self):
		Global.previous_scene = get_tree().get_current_scene().get_name()
		if (get_tree().get_current_scene().get_name() == "Graveyard"):
			Global.last_camera = get_viewport().get_camera().get_path()
			print(Global.last_camera)
			get_tree().change_scene("res://Scenes/House.tscn")
		elif (get_tree().get_current_scene().get_name() == "House"):
			get_tree().change_scene("res://Scenes/Graveyard.tscn")
	
func _on_Door_body_exited(body):
	if(body == self):
		pass

func _on_Area_body_entered(body, obj):
	if(body == self):
		can_interact = true
		target = obj

func _on_Area_body_exited(body, obj):
	if(body == self):
		can_interact = false
		target = null

func _on_CameraArea_body_entered(body, camera):
#	if (Global.current_camera != $"Head/Camera"): #and Global.current_camera != default_camera):
#		Global.previous_camera = get_viewport().get_camera()
#	Global.current_camera = camera
	if (body == self):
		if (Global.current_camera != $"Head/Camera" and Global.current_camera != default_camera):
			Global.previous_camera = get_viewport().get_camera()
		Global.current_camera = camera
		camera.current = true
		basis_buffer = true
		current_camera_area = camera.get_parent()

func _on_CameraArea_body_exited(body, camera):
	if (body == self):
		#basis_buffer = true
		print("exited")
		if (Global.previous_camera != Global.current_camera and current_camera_area == camera.get_parent()):
			default_camera.current = true
			print("changed camera")

