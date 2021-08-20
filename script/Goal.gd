extends Node2D

# File   : Goal.gd
# Author : Devin Arena
# Date   : 8/9/2021
# Purpose: Contains collision logic between ball and goal.

var game : Game

# Init function for Ball
func _ready() -> void:
	game = get_tree().root.get_node("Game")

# On collision with ball, make it reverse directions and slow down
# On collision with goalie, he stops completely
func _on_Outside_area_entered(area):
	if area is Ball:
		if not game.lost && not $Goal.playing && not $OutsideHit.playing:
			$OutsideHit.play()
		area.collided = true
		area.velocity *= -0.05
	if area is Goalie:
		area.velocity = Vector2()

# When the ball enters the net, the user scores a goal
func _on_Inside_area_entered(area):
	if area is Ball && not game.goal:
		if Data.gamemode == Data.GOALIE:
			game.lose()
			game.get_node("HUD").show_message_bar("GOAL!", Color(0.54, 0.14, 0.14, 1))
			$OutsideHit.play()
		else:
			$Goal.play()
			game.goal = true
			game.start_reset()
