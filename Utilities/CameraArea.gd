extends Area

onready var player = get_node("../../Player")
#onready var player = Global.player.instance()
onready var camera = $"Camera"

func _ready():
	#var arg = Array([camera])
	var arg = [camera, self]
	connect("body_entered", player, "_on_CameraArea_body_entered", arg)
	connect("body_exited", player, "_on_CameraArea_body_exited", arg)
