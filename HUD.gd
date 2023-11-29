extends CanvasLayer

func show_message(text):
	$HelpText.text = text
	$HelpText.show()

func hide_message():
	$HelpText.hide()


func _on_players_hand_text(text):
	show_message(text)
