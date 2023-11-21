extends Node2D

func _on_Card_hover_over_card(hovering, card):
	if (hovering):
		card.scale = Vector2(5,5)
	else:
		card.scale = Vector2(3,3)
