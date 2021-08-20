extends Node

# File   : SplashScreen.gd
# Author : Devin Arena
# Date   : 8/11/2021
# Purpose: Shows a splash screen before the game starts.

func _ready():
	$AnimationPlayer.play("fade")
	yield($AnimationPlayer, "animation_finished")
	Transition.change_to("res://scenes/Menu.tscn")
