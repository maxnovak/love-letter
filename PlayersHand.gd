extends Node2D

func _on_Card_hover_over_card(hovering, card):
	if (hovering):
		card.scale = Vector2(5,5)
	else:
		card.scale = Vector2(3,3)

func _on_Card_click(cardType, cardToRemove):
	if cardType == "priest":
		$"../OpponentHand".get_child(0)._set_visible(true)

	for card in self.get_children():
		if card != cardToRemove:
			card.position = Vector2(-50,0)

	var newCard = get_parent().deck.pop_front()
	newCard.position = Vector2(50,0)
	newCard._set_visible(true)
	self.add_child(newCard)

	newCard.hover_over_card.connect(self._on_Card_hover_over_card.bind(newCard))
	newCard.clicked_card.connect(self._on_Card_click.bind(newCard))

	cardToRemove.queue_free()
