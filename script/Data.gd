extends Node

# File   : Data.gd
# Author : Devin Arena
# Date   : 8/10/2021
# Purpose: Stores persistent data for the user and handles GPGS.

const FREE_KICKS = 0
const PENALTIES = 1
const GOALIE = 2

const file_path = "user://userdata.dat"

var gamemode : int = FREE_KICKS

var best_free_kicks : int = 0
var best_penalties : int = 0
var best_goalies : int = 0
var sound : float = 1.0
var music : float = 1.0

var gpgs
var achievements : Dictionary
var leaderboards : Dictionary

var test = false

func _ready() -> void:
	_load_data()
	_setup_gpgs()

# Loads user data such as highscores
func _load_data() -> void:
	var file = File.new()
	if not file.file_exists(file_path):
		return
	file.open(file_path, File.READ)
	var data : Dictionary = parse_json(file.get_line())
	if data.has("music"):
		music = data["music"]
		SoundManager.set_music_level(music)
	if data.has("sound"):
		sound = data["sound"]
		SoundManager.set_sfx_level(sound)
	if data.has("best_free_kicks"):
		best_free_kicks = data["best_free_kicks"]
	if data.has("best_penalties"):
		best_penalties = data["best_penalties"]
	if data.has("best_goalies"):
		best_goalies = data["best_goalies"]

# Saves user data such as highscores
func save_data() -> void:
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_line(to_json(serialize()))
	file.close()

# Sets up Google Play Game Services
func _setup_gpgs() -> void:
	if Engine.has_singleton("GodotPlayGamesServices"):
		gpgs = Engine.get_singleton("GodotPlayGamesServices")
		var request_token = "[REDACTED]"
		gpgs.init(true, false, false, request_token)
		
		if not gpgs.isGooglePlayServicesAvailable():
			return
		
		gpgs.signIn()
		
		_setup_achievements()
		_setup_leaderboards()
		
		print("Google Play Games Services")

# Sets up achievement dictionary
func _setup_achievements() -> void:
	achievements = {
		"15freekicks": "[REDACTED]",
		"15saves": "[REDACTED]",
		"15penalties": "[REDACTED]",
		"30freekicks": "[REDACTED]",
		"30saves": "[REDACTED]",
		"30penalties": "[REDACTED]",
	}

# Sets up achievement dictionary
func _setup_leaderboards() -> void:
	leaderboards = {
		"freekicks": "[REDACTED]",
		"goaliesaves": "[REDACTED]",
		"penalties": "[REDACTED]",
	}

# Awards a gpgs achievement if signed in
func award_achievement(id) -> void:
	if gpgs != null && gpgs.isSignedIn():
		gpgs.unlockAchievement(achievements[id])
	
# Show achievements if signed in
func show_achievements() -> void:
	if gpgs != null && gpgs.isSignedIn():
		gpgs.showAchievements()
		
# Sets a leaderboard if signed in
func submit_leaderboard(id, score) -> void:
	if gpgs != null && gpgs.isSignedIn():
		gpgs.submitLeaderBoardScore(leaderboards[id], score)

# Show all leaderboards if signed in
func show_leaderboards() -> void:
	if gpgs != null && gpgs.isSignedIn():
		gpgs.showAllLeaderBoards()
		
# Show a leaderboard if signed in
func show_leaderboard(id) -> void:
	if gpgs != null && gpgs.isSignedIn():
		gpgs.showLeaderBoard(id)

# Signs in if not already
func attempt_signin():
	if not gpgs.isSignedIn():
		gpgs.signIn()
		
# Signs out if signed in
func attempt_signout():
	if gpgs.isSignedIn():
		gpgs.signOut()

# Serializes save data
func serialize() -> Dictionary:
	return {
		"music": music,
		"sound": sound,
		"best_free_kicks": best_free_kicks, 
		"best_penalties": best_penalties,
		"best_goalies": best_goalies,
	}
