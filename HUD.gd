extends CanvasLayer

func show_message(card):
	$HelpText.text = card.description
	$HelpText.show()
	$CardName.clear()
	$CardName.push_bold()
	$CardName.append_text(card.cardName.to_pascal_case())
	$CardName.show()

func hide_message():
	$HelpText.hide()
	$CardName.hide()

func _on_players_hand_text(card):
	show_message(card)
