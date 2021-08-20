extends Control

# File   : HUD.gd
# Author : Devin Arena
# Date   : 8/10/2021
# Purpose: Contains logic for HUD elements.

var game : Game
var medal_colors : Array = [ Color(0.39, 0.33, 0.16), Color(0.5, 0.5, 0.5), Color(0.71, 0.76, 0.15), Color(0.46, 0.44, 0.51) ]
var medal_amounts : Array = [ 0, 10, 20, 30 ]

# Run when HUD initializes
func _ready() -> void:
	game = get_parent()
	$ShotButtons/DrivenShot.disabled = true
	$ShotButtons/InCurveShot.disabled = false
	$ShotButtons/OutCurveShot.disabled = false

# Displays the message bar with a custom message
func show_message_bar(text, color):
	$MessageBar/Text.text = text
	$MessageBar/Text.add_color_override("font_color", color)
	game.get_node("AnimationPlayer").play("messagebar")

# Displays the lose dialog
func show_lose_dialog():
	$LoseDialog.show()
	$LoseDialog/Container/ScoreRow/ScoreColumn/Text.text = str(game.score)
	var best : int = Data.best_free_kicks
	if Data.gamemode == Data.PENALTIES:
		best = Data.best_penalties
	elif Data.gamemode == Data.GOALIE:
		best = Data.best_goalies
	$LoseDialog/Container/ScoreRow/BestColumn/Text.text = str(best)
	for i in range(len(medal_amounts)):
		if game.score < medal_amounts[i]:
			$LoseDialog/Container/ScoreRow/Medal.modulate = medal_colors[i - 1]
			break
	
	# GPGS leaderboards
	if game.score > 0:
		if Data.gamemode == Data.FREE_KICKS:
			Data.submit_leaderboard("freekicks", game.score)
		elif Data.gamemode == Data.GOALIE:
			Data.submit_leaderboard("goaliesaves", game.score)
		elif Data.gamemode == Data.PENALTIES:
			Data.submit_leaderboard("penalties", game.score)

func _on_DrivenShot_pressed():
	$ShotButtons/DrivenShot.disabled = true
	$ShotButtons/InCurveShot.disabled = false
	$ShotButtons/OutCurveShot.disabled = false
	game.get_node("Ball").shot_type = game.get_node("Ball").DRIVEN

func _on_InCurveShot_pressed():
	$ShotButtons/InCurveShot.disabled = true
	$ShotButtons/DrivenShot.disabled = false
	$ShotButtons/OutCurveShot.disabled = false
	game.get_node("Ball").shot_type = game.get_node("Ball").INCURVE

func _on_OutCurveShot_pressed():
	$ShotButtons/OutCurveShot.disabled = true
	$ShotButtons/DrivenShot.disabled = false
	$ShotButtons/InCurveShot.disabled = false
	game.get_node("Ball").shot_type = game.get_node("Ball").OUTCURVE
