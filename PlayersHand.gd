extends Node2D

signal text

func _on_Card_hover_over_card(hovering, card):
	if (hovering):
		card.scale = Vector2(5,5)
		text.emit(Global.cardBreakdown[card._get_card()])
	else:
		card.scale = Vector2(3,3)
