extends Node

export var ui : NodePath

var panelNode
var isDialogueEvent = false
var dialogue = {}
var initStory
var currDialogue
var currChoices = []
var isChoice = false
var isChoiceDialogue = false
var isEnd = false
var events = {}
var choices = {}

var target

#TO-DO: Keep another file of "story flags" indicating
#actions player has done, use these to dictate how we should look up events
#and make an event handler with functions to decide what to
#return here based on the file
#TO-DO: Write truth values changed in dialogue processor back to this file
#returns the key to the initial dialogue branch

#Default path will always be "eventTarget" : <Target> : "Start" : ...
func choose_dialogue_branch(target):
	var possibleBranches = look_up_event(target)
	var branch = choose_dialogue(possibleBranches, Global.choices)
	if(branch != null):
		return branch
	elif(!possibleBranches["Start"]["Flag"]):
		possibleBranches["Start"]["Flag"] = true
		return possibleBranches["Start"]["Name"]
	elif("Repeat" in possibleBranches):
		possibleBranches["Repeat"]["Flag"] = true
		return possibleBranches["Repeat"]["Name"]
	else:
		possibleBranches["Start"]["Flag"] = true
		return possibleBranches["Start"]["Name"]
		
func choose_dialogue(possibilities, choices):
	for item in possibilities:
		if(item != "Start" and item != "Repeat"):
			if(choices[possibilities[item]["Flag"]]):
				return possibilities[item]["Name"]
	return null

func look_up_event(target):
	return events["eventTarget"][target]

func load_file_as_JSON(path):
	var file = File.new()
	file.open(path, file.READ)
	var content = (file.get_as_text())
	var dict = parse_json(content)
	
	file.close()
	return dict

func set_choice_values():
	var newLinkType = get_link_type(currDialogue[1])
	if(newLinkType == "divert"):
		isChoice = false
		isChoiceDialogue = false
	if(newLinkType == "linkPath" and isChoiceDialogue):
		isChoice = true
		isChoiceDialogue = false
	elif(newLinkType == "linkPath" and !isChoiceDialogue):
		isChoice = true
		isChoiceDialogue = true

func set_next_dialogue(target):
	if !("isEnd" in currDialogue[1]):
		var linkType = get_link_type(currDialogue[1])
		if(linkType == "divert"):
			currDialogue = initStory[currDialogue[1]["divert"]]["content"]
		set_choice_values()
	else:
		isEnd = true
		get_node("../Player").can_move = true
		get_node("../" + target).update_choices(Global.choices)
		panelNode.hide()
		#target = null
	
func get_link_type(dialogue):
	var linkType
	if dialogue.has("divert"):
		linkType = "divert"
	elif dialogue.has("linkPath"):
		linkType = "linkPath"
	return linkType

func advance_dialogue(target):
	if(isEnd):
		panelNode.hide()
	var textToShow = ""
	set_next_dialogue(target)
	textToShow = currDialogue[0]
	panelNode.get_node("Label").set_text(textToShow)
	panelNode.get_node("Label").visible_characters = 0

func _input(event):
	if target != null:
		if (event.is_action_pressed("interact")):
			if (panelNode.get_node("Label").visible_characters < currDialogue[0].length()):
				panelNode.get_node("Label").visible_characters = currDialogue[0].length()
			else:
				advance_dialogue(target)

#func _on_button_pressed(target):
#	if(isEnd):
#		panelNode.hide()
#	var textToShow = ""
#	set_next_dialogue(target)
#	textToShow = currDialogue[0]
#	panelNode.get_node("Label").set_text(textToShow)

func init_dialogue(target):
	isDialogueEvent = false
	initStory = null
	currDialogue = null
	currChoices = []
	isChoice = false
	isChoiceDialogue = false
	isEnd = false
	
	#get_node("../" + target).update_choices(Global.choices)
	
	target = choose_dialogue_branch(target)
	
	panelNode.show()
	
	initStory = dialogue["data"][target]
	currDialogue = initStory[initStory["initial"]]["content"]
	if currDialogue[1] != null:
		if currDialogue[1].has("divert"):
			isChoice = false
			isChoiceDialogue = false
		if currDialogue[1].has("linkPath"):
			isChoice = true
			isChoiceDialogue = true
	panelNode.get_node("Label").set_text(currDialogue[0])
	panelNode.get_node("Label").visible_characters = 0
	

func update_choices():
	pass

func _ready():
	set_process_input(true)
	
	dialogue = load_file_as_JSON("res://JSON/Dialogue.json")
	events = load_file_as_JSON("res://JSON/Events.json")
	choices = load_file_as_JSON("res://JSON/Choices.json")
	
	panelNode = $"../UI/Panel"
	
	if(panelNode.is_visible()):
		panelNode.hide()
