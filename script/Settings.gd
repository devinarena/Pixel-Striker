extends Node

# File   : Settings.gd
# Author : Devin Arena
# Date   : 8/11/2021
# Purpose: Contains settings logic.

func _ready():
	$Control/Container/MusicSliderContainer/MusicSlider.value = Data.music
	$Control/Container/SFXSliderContainer/SFXSlider.value = Data.sound

# Return to home page on home button pressed
func _on_HomeButton_pressed():
	Data.save_data()
	Transition.change_to("res://scenes/Menu.tscn")

func _on_MusicSlider_value_changed(value):
	Data.music = value
	SoundManager.set_music_level(Data.music)

func _on_SFXSlider_value_changed(value):
	Data.sound = value
	SoundManager.set_sfx_level(Data.sound)
