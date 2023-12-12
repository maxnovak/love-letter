extends Node2D

signal clicked

var playerName: String = "": set = _set_playerName, get = _get_playerName
func _set_playerName(new_value):
	playerName = new_value
	$PlayerName.text = new_value
func _get_playerName():
		return playerName

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		clicked.emit()
