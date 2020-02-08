extends Node

var player = preload("res://Player/Player.tscn")
var door = preload("res://Scenes/Door.tscn")

var current_camera
var previous_camera
var last_camera = null

var current_camera_basis
var previous_camera_basis

var current_scene
var previous_scene

var choices = {}

var is_shaking = false
var elapsed_time = 0

func update_choices(choice, state):
	choices[choice] = state

func get_choices(choices, choice):
	return choices[choice]

func load_file_as_JSON(path):
	var file = File.new()
	file.open(path, file.READ)
	var content = (file.get_as_text())
	var dict = parse_json(content)
	
	file.close()
	return dict

func _ready():
	choices = load_file_as_JSON("res://JSON/Choices.json")

func _process(delta):
	if (is_shaking):
		shake_window(delta)

func shake_window(delta):
	if (OS.window_fullscreen):
		OS.window_fullscreen = false
	var shake_time = 0.7
	var shake_x = rand_range(0, OS.get_screen_size().x)
	var shake_y = rand_range(0, OS.get_screen_size().y)
	if (elapsed_time < shake_time):
		OS.window_position = Vector2(shake_x, shake_y)
		elapsed_time += delta
	else:
		is_shaking = false
		elapsed_time = 0
		get_tree().quit()
