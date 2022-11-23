extends Control
# This merely needs to display the title screen
onready var start_button = $VBoxContainer/Button
onready var game = preload("res://FastMatchGame.tscn")
# I wanted to change the outline size of the start button
# font and apply a glow via a WorldEnvironment to make it
# more visually interesting, but you cannot change theme
# overrides at runtime, and I am not sure it is even
# possible for WorldEnvironment to affect Control nodes.
# Downside to doing all of the design via built-ins, I guess
# Oh well

func _on_Button_pressed():
	get_tree().change_scene_to(game)
