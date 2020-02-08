extends Label

var start = false

func _ready():
	visible_characters = 0

func _on_Timer_timeout():
	visible_characters += 1
