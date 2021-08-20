extends Area2D

class_name Goalie

# File   : Goalie.gd
# Author : Devin Arena
# Date   : 8/9/2021
# Purpose: Contains collision logic between ball and goalie.
#		   Attempts to dive towards the ball (normally badly)

var ball : Ball
var velocity : Vector2
var dove : bool = false
var hold_ball : bool = false
var holding : bool = false

# Player input (for goalie mode)
var swipe : Vector2
var swiping : bool = false
var swipe_timer : int

var speed : int = 310

var game : Game

# Init function for Goalie
func _ready() -> void:
	game = get_tree().root.get_node("Game")
	ball = game.get_node("Ball")

# Handles diving logic
func _process(delta) -> void:
	position += velocity * delta
	if Data.gamemode == Data.GOALIE:
		pass
	else:
		if not dove and ball.velocity.length_squared() > 0:
			if Data.gamemode == Data.FREE_KICKS:
				if abs(ball.position.x - position.x) < 104 && abs(ball.position.y - position.y) > 32:
					dove = true
					velocity = Vector2(0, ball.position.y - position.y).normalized() * speed
					$Sprite.flip_v = velocity.y > 0
					$Sprite.frame = 1
			elif Data.gamemode == Data.PENALTIES:
					dove = true
					var far : int = int(randf() < 0.5) + 1
					velocity = Vector2(0, (randf() - randf()) * far) * speed * 0.9
					$Sprite.flip_v = velocity.y > 0
					$Sprite.frame = 1
	if holding:
		ball.position = position - Vector2(32, 0)
	velocity *= 0.955

# When the goalie touches the ball, he swats it away
func _on_Goalie_area_entered(area):
	if area is Ball:
		if not area.collided:
			$Smack.play()
		if hold_ball && not holding && not game.goal && not game.lost:
			holding = true
			$Sprite.frame = 2
		else:
			area.velocity = Vector2(area.velocity.x * -0.6, area.velocity.y)
		area.collided = true

# When the screen is swiped (Goalie mode)
func _input(event):
	if Data.gamemode != Data.GOALIE:
		return
	if dove or holding:
		return
	if event is InputEventMouseButton:
		if not swiping && event.pressed:
			swiping = true
			swipe = event.position
			swipe_timer = OS.get_ticks_msec()
		else:
			if swipe != null:
				var diff : Vector2 = event.position - swipe
				var dir : Vector2 = diff.normalized()
				var spd = speed * diff.length_squared() / ((OS.get_ticks_msec() - swipe_timer) * (OS.get_ticks_msec() - swipe_timer))
				velocity = dir * min(spd, speed)
				dove = true
				swiping = false
				$Sprite.flip_v = velocity.y > 0
				$Sprite.frame = 1
