extends Node2D

signal startGame(numberOfPlayers: int)

func _on_start_pressed():
	startGame.emit($NumberOfPlayers.get_selected_id())
