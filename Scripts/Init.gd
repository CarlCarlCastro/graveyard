extends Node

func _ready():
	OS.window_size = OS.get_screen_size() / 2
	OS.center_window()
	var player = get_node("Player")
	var interactables = get_tree().get_nodes_in_group("Interactable")
	for i in range(interactables.size()):
		var currNode = get_node(interactables[i].get_path())
		var areaNode = currNode.get_node("Area")
		var args = Array([currNode])
		if areaNode != null:
			areaNode.connect("body_entered", player, "_on_Area_body_entered", args)
			areaNode.connect("body_exited", player, "_on_Area_body_exited", args)
	

	var door = Global.door.instance()
	var door_parent = $"HouseParent/DoorParent"
	door_parent.add_child(door)
	door.set_translation(Vector3(door_parent.translation.x, door_parent.translation.y, door_parent.translation.z))
	door.connect("body_entered", player, "_on_Door_body_entered")
	door.connect("body_exited", player, "_on_Door_body_exited")
	Global.current_scene = get_tree().get_current_scene()
	
	player.default_camera = $"CameraAreas/CameraArea2/Camera"
	
	var pos = $Position3D
	if (Global.previous_scene != null):
		if (Global.previous_scene== "House"):
			player.set_translation(pos.translation)
			var last_camera = get_node(Global.last_camera)
			last_camera.current = true
	
	if (Global.choices["talkedGirl1"] and Global.choices["readDiary1"]):
		$Girl.set_translation($Girl2.translation)
		$"CameraAreas/CameraArea3/CollisionShape".disabled = true
		$"CameraAreas/CameraArea5/CollisionShape".disabled = false
	elif (Global.choices["talkedGirl2"] and Global.choices["readDiary2"]):
		$"CameraAreas/CameraArea3/CollisionShape".disabled = true
		$Girl.set_translation($Girl3.translation)
	
	Global.current_camera = get_viewport().get_camera()
	Global.previous_camera = get_viewport().get_camera()
