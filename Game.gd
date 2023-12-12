extends Node2D

var tableScene = preload("res://table.tscn")

func new_game(numberOfPlayers: int):
	$NewGame.hide()
	var table = tableScene.instantiate()
	table.setup(numberOfPlayers)
	get_tree().root.add_child(table)
