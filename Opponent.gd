extends Node2D

signal clicked

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		clicked.emit(true)
