extends Node2D

signal playCard

func _process(delta):
	if self.get_child_count() == 2:
		playCard.emit(self.get_child(0))
