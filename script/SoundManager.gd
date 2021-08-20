extends Node

# File   : SoundManager.gd
# Author : Devin Arena
# Date   : 8/11/2021
# Purpose: Contains logic for sound.

func _ready():
	pass

# Sets the music level in DB using a percentage 0-1
func set_music_level(vol):
	var index : int = AudioServer.get_bus_index("MUSIC")
	var db : float = (1 - Data.music) * -40.0
	AudioServer.set_bus_volume_db(index, db)
	
# Sets the sfx level in DB using a percentage 0-1
func set_sfx_level(vol):
	var index : int = AudioServer.get_bus_index("SFX")
	var db : float = (1 - Data.sound) * -40.0
	AudioServer.set_bus_volume_db(index, db)

# Sometimes looping doesn't work on Godot, so I do it manually
func _on_Music_finished():
	$Music.play()
