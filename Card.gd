extends Node

signal hover_over_card
signal clicked_card

const pickedSuit = "Clubs"
const hiddenCard = preload("res://assets/Cards/Backs/back_0.png")

var card: String = "": set = _set_card, get = _get_card
func _set_card(new_value):
	card = new_value
func _get_card():
		return card

var visible: bool = false: set = _set_visible, get = _get_visible
func _set_visible(new_value):
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": Global.cardBreakdown[card].assetName})
	var visibleCard = load(path)
	$Sprite2D.texture = visibleCard
	visible = new_value
func _get_visible():
	return visible


func setup(cardType: String, visibility: bool):
	card = cardType
	visible = visibility
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": Global.cardBreakdown[cardType].assetName})
	var visibleCard = load(path)

	if visible:
		$Sprite2D.texture = visibleCard
	else:
		$Sprite2D.texture = hiddenCard

func _on_area_2d_mouse_entered():
	hover_over_card.emit(true)

func _on_area_2d_mouse_exited():
	hover_over_card.emit(false)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		clicked_card.emit(card)
