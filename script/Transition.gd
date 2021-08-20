extends CanvasLayer

# File   : Transition.gd
# Author : Devin Arena
# Date   : 8/10/2021
# Purpose: Allows smooth transitions between states.

func _ready() -> void:
	pass

# Changes to the specified scene after transitioning
func change_to(scene):
	$ColorBox.show()
	$ColorBox.mouse_filter = Control.MOUSE_FILTER_STOP
	$AnimationPlayer.play("fade")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(scene)
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	$ColorBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorBox.hide()
	
