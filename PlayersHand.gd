extends Node2D

func _on_Card_hover_over_card(hovering, card):
	if (hovering):
		card.scale = Vector2(5,5)
	else:
		card.scale = Vector2(3,3)

func _on_Card_click(card):
	# take action
	if card == "priest":
		$"../OpponentHand".get_child(0)._set_visible(true)
