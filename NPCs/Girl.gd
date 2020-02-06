extends StaticBody

onready var player = get_node("../Player")
onready var area = $Area
var talk_counter = 0

func _ready():
	pass#if area != null:
	#	area.connect("body_entered", player, "_on_Area_body_entered")

func update_choices(choices):
	
	if (!Global.choices["talkedGirl1"] and !Global.choices["talkedGirl2"] and !Global.choices["talkedGirl3"]):
		choices["talkedGirl1"] = true
		Global.update_choices(choices["talkedGirl1"], true)
	elif (Global.choices["talkedGirl1"] and Global.choices["readDiary1"]):
		choices["talkedGirl1"] = false
		choices["talkedGirl2"] = true
		Global.update_choices(choices["talkedGirl1"], false)
		Global.update_choices(choices["talkedGirl2"], true)
	elif (Global.choices["talkedGirl2"] and Global.choices["readDiary2"]):
		choices["talkedGirl2"] = false
		choices["talkedGirl3"] = true
		Global.update_choices(choices["talkedGirl2"], false)
		Global.update_choices(choices["talkedGirl3"], true)
	elif (Global.choices["talkedGirl3"] and Global.choices["readDiary3"]):
		player.can_move = false
		OS.window_fullscreen = false
		OS.set_window_title("diediediediediediedie")
		Global.is_shaking = true
#	talk_counter += 1
#	if (talk_counter == 1):
#		choices["talkedGirl1"] = true
#		Global.update_choices(choices["talkedGirl1"], true)
#	elif (talk_counter == 2):
#		choices["talkedGirl1"] = false
#		choices["talkedGirl2"] = true
#		Global.update_choices(choices["talkedGirl1"], false)
#		Global.update_choices(choices["talkedGirl2"], true)
#	elif (talk_counter == 3):
#		choices["talkedGirl2"] = false
#		choices["talkedGirl3"] = true
#		Global.update_choices(choices["talkedGirl2"], false)
#		Global.update_choices(choices["talkedGirl3"], true)
#
#	print("Girl talk counter: " + str(talk_counter))
#	print(choices)
