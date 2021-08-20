extends Node

class_name Game

# File   : Game.gd
# Author : Devin Arena
# Date   : 8/9/2021
# Purpose: Contains main game logic.

const goalie_x : int = 656

var start_position : Vector2

var score : int = 0
var lost : bool = false
var goal : bool = false

# Init function for Game
func _ready() -> void:
	randomize()
	start_position = Vector2(272, 192)
	$Ball.position = _random_position() if Data.gamemode == Data.FREE_KICKS else start_position
	$Goalie.position = Vector2(goalie_x, 96 + randi() % int(get_viewport().get_visible_rect().size.y - 192)) if Data.gamemode == Data.FREE_KICKS else Vector2(goalie_x, get_viewport().get_visible_rect().size.y / 2)
	if Data.gamemode == Data.GOALIE:
		_init_goalie()
	
# Starts the reset timer, in a few seconds the ball will be
# reset for the player to take another shot.
func start_reset() -> void:
	$ResetTimer.start()

# Called when the player misses, shows the lose dialog
func lose() -> void:
	lost = true

# Called when the play retries, resets everything
func reset() -> void:
	score = 0
	$HUD/Container/Score.text = str(score)
	_reset_positions()

# Resets the positions of objects for the next round
func _reset_positions():
	$Ball.rotation = 0
	$Ball.curve_speed = 0
	$Ball.velocity = Vector2()
	
	$Goalie.velocity = Vector2()
	$Goalie.dove = false
	$Goalie.hold_ball = false
	$Goalie.holding = false
	$Goalie.get_node("Sprite").frame = 0
	
	var bp : Vector2 = start_position
	if Data.gamemode != Data.PENALTIES:
		bp = _random_position()
	var gp : Vector2 = Vector2(goalie_x, get_viewport().get_visible_rect().size.y / 2)
	if Data.gamemode == Data.FREE_KICKS:
		gp = Vector2(goalie_x, 96 + randi() % int(get_viewport().get_visible_rect().size.y - 192))
	
	$Tween.interpolate_property($Ball, "position", $Ball.position, bp, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Goalie, "position", $Goalie.position, gp, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

# Generates a random position for the ball
func _random_position():
	return start_position - Vector2(32, 128) + randf() * Vector2(64, 256)

# Called if this is a goalie game, removes shot buttons
func _init_goalie():
	$HUD/ShotButtons.hide()

# Runs when reset timer times out, if the game is lost, prompt the user to
# retry, otherwise increment score and reset positions.
func _on_ResetTimer_timeout():
	score += 1
	$HUD/Container/Score.text = str(score)
	
	if score > 0:
		if Data.gamemode == Data.GOALIE:
			$HUD.show_message_bar("SAVE!", Color(0.14, 0.54, 0.45, 1))
		else:
			$HUD.show_message_bar("GOAL!", Color(0.14, 0.54, 0.45, 1))
		$Win.play()
		
		if Data.gamemode == Data.FREE_KICKS:
			if score > Data.best_free_kicks:
				Data.best_free_kicks = score
				Data.save_data()
			if score >= 30:
				Data.award_achievement("30freekicks")
			elif score >= 15:
				Data.award_achievement("15freekicks")
		elif Data.gamemode == Data.PENALTIES:
			if score > Data.best_penalties:
				Data.best_penalties = score
				Data.save_data()
			if score >= 30:
				Data.award_achievement("30penalties")
			elif score >= 15:
				Data.award_achievement("15penalties")
		elif Data.gamemode == Data.GOALIE:
			if score > Data.best_goalies:
				Data.best_goalies = score
				Data.save_data()
			if score >= 30:
				Data.award_achievement("30saves")
			elif score >= 15:
				Data.award_achievement("15saves")
	
	_reset_positions()

# When the tween completes, the ball can be shot again
func _on_Tween_tween_all_completed():
	goal = false
	lost = false
	$Ball.collided = false
	$Ball.shot = false
	$Goalie.hold_ball = randf() < 0.5
	
	if Data.gamemode == Data.GOALIE:
		$Ball.get_node("Timer").wait_time = 1 + randf()
		$Ball.get_node("Timer").start()

# When user clicks the retry button, reset
func _on_RetryButton_pressed():
	reset()
	$HUD/LoseDialog.hide()

# When the animation player finishes, used to show the lose dialog
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "messagebar" && lost:
		$HUD.show_lose_dialog()

# When the home button is pressed, navigate to the home screen
func _on_HomeButton_pressed():
	Transition.change_to("res://scenes/Menu.tscn")
