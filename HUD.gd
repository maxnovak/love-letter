extends CanvasLayer

func show_message(cardType):
	var card = Global.cardBreakdown[cardType]
	$HelpText.text = card.description
	$HelpText.show()
	$CardName.clear()
	$CardName.push_bold()
	$CardName.append_text(card.cardName.to_pascal_case())
	$CardName.show()

func hide_message():
	$HelpText.hide()
	$CardName.hide()

func _on_players_hand_text(cardType):
	show_message(cardType)

func show_instruction(text):
	$Instruction.text = text
	$Instruction.show()

func hide_instruction():
	$Instruction.hide()
