extends Spatial

func _ready():
#	var player_scene = preload("res://Player/Player.tscn")
#	var player = player_scene.instance()
	var player = Global.player.instance()
	self.add_child(player)
	var player_camera = $"Player/Head/Camera"
	Global.previous_camera = null
	Global.current_camera = player_camera
	Global.current_scene = get_tree().get_current_scene()
	
	var interactables = get_tree().get_nodes_in_group("Interactable")
	for i in range(interactables.size()):
		var currNode = get_node(interactables[i].get_path())
		var areaNode = currNode.get_node("Area")
		var args = Array([currNode])
		if areaNode != null:
			areaNode.connect("body_entered", player, "_on_Area_body_entered", args)
			areaNode.connect("body_exited", player, "_on_Area_body_exited", args)
	
	var pos = $Position3D
	player.set_translation(Vector3(pos.translation.x, pos.translation.y, pos.translation.z))
	player.set_rotation(pos.rotation)

	var door = Global.door.instance()
	var door_parent = $"DoorParent"
	door_parent.add_child(door)
	door.set_translation(Vector3(door_parent.translation.x, door_parent.translation.y, door_parent.translation.z))
	door.connect("body_entered", player, "_on_Door_body_entered")
	door.connect("body_exited", player, "_on_Door_body_exited")
