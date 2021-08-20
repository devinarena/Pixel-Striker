extends Area2D

class_name Ball

# File   : Ball.gd
# Author : Devin Arena
# Date   : 8/9/2021
# Purpose: Player attempts to shoot the ball into the goal.

const MAX_SPEED : int = 1000
const MAX_DRAG : float = 192.0

const DRIVEN = 0
const INCURVE = 1
const OUTCURVE = 2

var velocity : Vector2
var curve_speed : float = 0
var pressed : bool = false
var shot : bool = false
var collided : bool = false
var rotation_dir : int = 0

var shot_type : int = DRIVEN

var game : Game
var goal

# Init function for Ball
func _ready() -> void:
	game = get_tree().root.get_node("Game")
	goal = game.get_node("Goal")

# Updates the ball every frame, notably updates position
# based on velocity.
func _process(delta) -> void:
	position += velocity * delta
	# Calculates rotation based on velocity (if moving)
	if velocity.length_squared() > 1:
		var amt : float = PI * velocity.length_squared() / (16 * MAX_SPEED * MAX_SPEED)
		rotation += amt * rotation_dir
		velocity *= 0.9925 if not collided else 0.965 # friction
		if not collided && velocity.length_squared() > 10 * 10:
			if shot_type == INCURVE:
				velocity.y += curve_speed
			elif shot_type == OUTCURVE:
				velocity.y += curve_speed
			curve_speed *= 0.98
	else: 
		# if not moving, and haven't won, lose
		if shot && not game.lost && not game.goal && game.get_node("ResetTimer").is_stopped():
			if Data.gamemode == Data.GOALIE:
				if not game.goal:
					game.goal = true
					game.get_node("ResetTimer").emit_signal("timeout")
			else:
				game.get_node("HUD").show_message_bar("MISS!", Color(0.54, 0.14, 0.14, 1))
				game.lose()
	if not game.lost:
		if not collided:
			if position.x > get_viewport_rect().size.x + 32 || position.x < -32 || position.y > get_viewport_rect().size.y + 32 || position.y < -32:
				if Data.gamemode == Data.GOALIE:
					game.start_reset()	
					collided = true
				else:
					game.get_node("HUD").show_message_bar("OUT!", Color(0.54, 0.14, 0.14, 1))
					game.lose()
	update()

# Used to draw a line for the direction of shot
func _draw():
	if pressed:
		var pos : Vector2 = get_local_mouse_position()
		if pos.length_squared() > 160 * 160:
			pos = pos.normalized() * 160
		var r : float = pos.length_squared() / (160 * 160)
		draw_line(pos / 2, -pos, Color(r, 0, 0, 1), 1.5, true)

# Handles when the ball is released, flings the ball
# based on original tap and release positions.
func _input(event) -> void:
	if Data.gamemode == Data.GOALIE:
		return
	if pressed:
		if event is InputEventMouseButton:
			if not event.pressed:
				pressed = false
				var df : float = max(0, 192 - sqrt(pow(position.x - event.position.x, 2) + pow(position.y - event.position.y, 2)))
				var dir : Vector2 = (position - event.position).normalized()
				var force : Vector2 = dir * (1 - df / MAX_DRAG)
				if force.length_squared() > 0.1 * 0.1:
					shot = true
					var total : int = MAX_SPEED
					if shot_type == DRIVEN:
						total += 100
					velocity = force * total
					rotation_dir = 1 if velocity.y > 0 else -1
					if shot_type == INCURVE:
						curve_speed = (1 - df / MAX_DRAG) * 10.0 * dir.x if velocity.y < 0 else (1 - df / MAX_DRAG) * -10.0 * dir.x
					elif shot_type == OUTCURVE:
						curve_speed = (1 - df / MAX_DRAG) * 8.0 * dir.x if velocity.y > 0 else (1 - df / MAX_DRAG) * -8.0 * dir.x
					$Kick.play()

# Handles when the ball is tapped, stores tap info.
func _on_Ball_input_event(viewport, event, shape_idx) -> void:
	if Data.gamemode == Data.GOALIE:
		return
	if event is InputEventMouseButton:
		if event.pressed && not shot:
			pressed = true

# When the timer runs out on goalie mode, the ball is shot toward the goal
func _on_Timer_timeout():
	if Data.gamemode != Data.GOALIE:
		return
	var dX : float = get_viewport_rect().size.x + 32
	var dY : float = randf() * (get_viewport_rect().size.y / 2 - 64)
	dY += get_viewport_rect().size.y / 2 if randf() < 0.5 else 128
	var vel : Vector2 = (Vector2(dX, dY) - position).normalized()
	if abs(vel.x) > 0.5:
		vel.x /= 2
	var spd = (0.9 + randf() * 0.1) * (MAX_SPEED * 1.5)
	print(spd)
	velocity = vel * spd
	shot = true
	rotation_dir = sign(velocity.y)
	var chance : float = randf()
	if chance < 0.2:
		curve_speed = -10.0 * rotation_dir * (spd / (MAX_SPEED * 1.5))
	elif chance < 0.4:
		curve_speed = 8.0 * rotation_dir * (spd / (MAX_SPEED * 1.5))
