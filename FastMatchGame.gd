extends Control

# Timer display
onready var timer = $Timer
onready var hud_time = $HUD/Time/Dynamic
# Score tracking and display
onready var hud_score = $HUD/Score/Dynamic
var score: int = 0
var mult: int = 1
onready var hud_streak = $HUD/Streak/VBoxContainer/Counters/Dynamic
var streak: int = 0
onready var streak_1 = $HUD/Streak/VBoxContainer/Counters/Streak1
onready var streak_2 = $HUD/Streak/VBoxContainer/Counters/Streak2
onready var streak_3 = $HUD/Streak/VBoxContainer/Counters/Streak3
onready var streak_4 = $HUD/Streak/VBoxContainer/Counters/Streak4
onready var streak_5 = $HUD/Streak/VBoxContainer/Counters/Streak5
var light_streak = Color("3ba656")
var dark_streak = Color("de323232")
# Remember last card and display new one
var last_card: int
var this_card: int
var rng = RandomNumberGenerator.new()
onready var card_shown = $VBoxContainer/CardPiles/Card
var card1 = preload("res://Assets/card1.png")
var card2 = preload("res://Assets/card2.png")
var card3 = preload("res://Assets/card3.png")
var card4 = preload("res://Assets/card4.png")
var card5 = preload("res://Assets/card5.png")
var card0 = preload("res://Assets/blankcard.png")
# Need to prevent extra inputs
var player_ready = false
# Initialize audio
onready var right_sound = $CorrectSound
onready var wrong_sound = $WrongSound
onready var ding_sound = $CountSound
# Countdown timer
onready var countdown = $Countdown
onready var count_label = $Countdown/Label

func _ready():
	rng.randomize()
	# Initialize random card
	this_card = rng.randi_range(1,5)
	_show_card(this_card)
	# Short pause before starting, display countdown timer
	count_label.text = "3"
	countdown.popup()
	yield(get_tree().create_timer(.9),"timeout")
	ding_sound.play()
	countdown.hide()
	yield(get_tree().create_timer(.1),"timeout")
	count_label.text = "2"
	countdown.popup()
	yield(get_tree().create_timer(.9),"timeout")
	ding_sound.play()
	countdown.hide()
	yield(get_tree().create_timer(.1),"timeout")
	count_label.text = "1"
	countdown.popup()
	yield(get_tree().create_timer(.9),"timeout")
	ding_sound.play()
	countdown.hide()
	yield(get_tree().create_timer(.2),"timeout")
	_change_card()
	
	timer.start(45)

func _input(event):
	# Prevent input spam by checking for echoes
	if player_ready and !event.is_echo():
		if event.is_action("ui_left"):
			_on_NoButton_pressed()
		elif event.is_action("ui_right"):
			_on_YesButton_pressed()

func _process(_delta):
	# Update HUD elements
	hud_time.text = String(int(timer.time_left)) + " sec"
	hud_score.text = String(score)
	hud_streak.text = "x"+String(mult)

func _show_card(card):
	# Relate random number selected to an image
	match card:
		1:
			card_shown.texture = card1
		2:
			card_shown.texture = card2
		3:
			card_shown.texture = card3
		4:
			card_shown.texture = card4
		5:
			card_shown.texture = card5

func _change_card():
	# Prevent input until animation completes
	player_ready = false
	# Store previous card before showing new one
	last_card = this_card
	this_card = rng.randi_range(1,5)
	# Put new card under old card	
	# First duplicate the card
	var card_stack = card_shown.duplicate(8)
	# Set the position relative to parent
	card_stack.rect_position = Vector2(0,0)
	# Set the new card underneath
	_show_card(this_card)
	# Add old card as child of new card because children
	# are drawn over their parents by default
	$VBoxContainer/CardPiles/Card.add_child(card_stack)
	# tween last card away
	var tween = create_tween()
	yield(tween.tween_property(card_stack,"rect_position",-Vector2(96,0),.15),"finished")
	# Flip card
	card_stack.texture = card0
	card_stack.self_modulate = Color("142661")
	# Finish tweening flipped card
	# Have to create new tween because tweens auto-free
	tween = create_tween()
	yield(tween.tween_property(card_stack,"rect_position",-Vector2(104,0),.15),"finished")
	card_stack.queue_free()
	# Allow input again
	player_ready = true


func _check_card(ans):
	# Check if this card matches last card
	match ans:
		1:	# This choice is when Yes is pressed
			if this_card == last_card:
				_up_score()
			else:
				_end_streak()
		0:	# This is when No is pressed
			if this_card != last_card:
				_up_score()
			else: _end_streak()
	# Regardless of result, change card
	_change_card()

func _up_score():
	# Increase streak counter
	streak += 1
	# Light up a streak counter in hud
	match streak:
		1:
			streak_1.self_modulate = light_streak
		2:
			streak_2.self_modulate = light_streak
		3:
			streak_3.self_modulate = light_streak
		4:
			streak_4.self_modulate = light_streak
		5:
			streak_5.self_modulate = light_streak
		6:
			streak = 0
			_clear_streaks()
			# Increase score multiplier
			mult += 1
			if mult > 20:
				mult = 20
	# Play sound and increment score
	right_sound.play()
	score += 66*mult

func _clear_streaks():
	# Remove streak highlights from hud
	streak_1.self_modulate = dark_streak
	streak_2.self_modulate = dark_streak
	streak_3.self_modulate = dark_streak
	streak_4.self_modulate = dark_streak
	streak_5.self_modulate = dark_streak
	
func _end_streak():
	# Play sound
	wrong_sound.play()
	# Decrease multiplier and clear streak counters
	mult -= 1
	streak = 0
	if mult < 1:
		mult = 1
	_clear_streaks()


func _end_game():
	# Stop accepting input and display popup menu
	player_ready = false
	$UI/NoButton.disabled = true
	$UI/YesButton.disabled = true
	get_tree().paused = true
	$PopupDialog.popup()


func _on_Timer_timeout():
	# End game
	_end_game()


func _on_YesButton_pressed():
	# Extra check to prevent input spam
	if player_ready:
		_check_card(1)

func _on_NoButton_pressed():
	# Extra check to prevent input spam
	if player_ready:
		_check_card(0)


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()
	# Re-enable buttons
	$UI/NoButton.disabled = false
	$UI/YesButton.disabled = false
	# Unpause tree
	get_tree().paused = false
