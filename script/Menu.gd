extends Node

# File   : Menu.gd
# Author : Devin Arena
# Date   : 8/10/2021
# Purpose: Contains logic for Menu elements.

func _ready():
	Data.gpgs.connect("_on_sign_in_success", self, "_on_sign_in_success")
	Data.gpgs.connect("_on_sign_out_success", self, "_on_sign_out_success")
	if Data.gpgs != null && Data.gpgs.isSignedIn():
		_on_sign_in_success("")
	else:
		_on_sign_out_success()

# Called when the freekicks button is pressed, changes to game scene
func _on_FreeKicks_pressed():
	Data.gamemode = Data.FREE_KICKS
	Transition.change_to("res://scenes/Game.tscn")

# Called when the penalties button is pressed, changes to game scene
func _on_Penalties_pressed():
	Data.gamemode = Data.PENALTIES
	Transition.change_to("res://scenes/Game.tscn")

# Called when the goalie button is pressed, changes to game scene
func _on_Goalie_pressed():
	Data.gamemode = Data.GOALIE
	Transition.change_to("res://scenes/Game.tscn")

func _on_Settings_pressed():
	Transition.change_to("res://scenes/Settings.tscn")

# Called when signed in, changes the sign in button to a
# sign out button and shows all other buttons
func _on_sign_in_success(account_id):
	$GUI/GPGSButtons/SignInButton.hide()
	$GUI/GPGSButtons/SignOutButton.show()
	$GUI/GPGSButtons/LeaderboardsButton.show()
	$GUI/GPGSButtons/AchievementsButton.show()

# Called when signed out, changes the sign out button to a
# sign in button and hides all other buttons
func _on_sign_out_success():
	$GUI/GPGSButtons/SignInButton.show()
	$GUI/GPGSButtons/SignOutButton.hide()
	$GUI/GPGSButtons/LeaderboardsButton.hide()
	$GUI/GPGSButtons/AchievementsButton.hide()

# Called when the sign-in button is pressed, signs
# the user into Google Play Games Services
func _on_SignInOutButton_pressed():
	if Data.gpgs == null:
		return
	Data.attempt_signin()
		
# Called when the sign-in button is pressed, signs
# the user out of Google Play Games Services
func _on_SignOutButton_pressed():
	if Data.gpgs == null:
		return
	Data.attempt_signout()

# Shows leaderboards when the leaderboards button is pressed
func _on_LeaderboardsButton_pressed():
	Data.show_leaderboards()

# Shows achievements when the # Shows achievements when the leaderboards button is pressed button is pressed
func _on_AchievementsButton_pressed():
	Data.show_achievements()

