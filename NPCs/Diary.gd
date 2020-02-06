extends StaticBody

var talk_counter = 0

func _ready():
	pass

func update_choices(choices):
	
	if (!Global.choices["readDiary1"] and !Global.choices["readDiary2"] and !Global.choices["readDiary3"] and Global.choices["talkedGirl1"]):
		choices["readDiary1"] = true
		Global.update_choices(choices["readDiary1"], true)
	elif (Global.choices["readDiary1"] and Global.choices["talkedGirl2"]):
		choices["readDiary1"] = false
		choices["readDiary2"] = true
		Global.update_choices(choices["readDiary1"], false)
		Global.update_choices(choices["readDiary2"], true)
	elif (Global.choices["readDiary2"] and Global.choices["talkedGirl3"]):
		choices["readDiary2"] = false
		choices["readDiary3"] = true
		Global.update_choices(choices["readDiary2"], false)
		Global.update_choices(choices["readDiary3"], true)
	
#	talk_counter += 1
#	if (talk_counter == 1):
#		choices["readDiary1"] = true
#		Global.update_choices(choices["readDiary1"], true)
#	elif (talk_counter == 2):
#		choices["readDiary1"] = false
#		choices["readDiary2"] = true
#		Global.update_choices(choices["readDiary1"], false)
#		Global.update_choices(choices["readDiary2"], true)
#	elif (talk_counter == 3):
#		choices["readDiary2"] = false
#		choices["readDiary3"] = true
#		Global.update_choices(choices["readDiary2"], false)
#		Global.update_choices(choices["readDiary3"], true)
#	print("Diary talk counter: " + str(talk_counter))
#	print(choices)
