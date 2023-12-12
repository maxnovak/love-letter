extends Node

signal hover_over_card(cardType)
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


func setup(cardType: String, visibility: bool, noHover: bool = false):
	card = cardType
	visible = visibility
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": Global.cardBreakdown[cardType].assetName})
	var visibleCard = load(path)

	if visible:
		$Sprite2D.texture = visibleCard
	else:
		$Sprite2D.texture = hiddenCard

	if noHover:
		$Area2D.mouse_entered.disconnect(self._on_area_2d_mouse_entered)
		$Area2D.mouse_exited.disconnect(self._on_area_2d_mouse_exited)

func _on_area_2d_mouse_entered():
	self.scale = Vector2(5,5)
	hover_over_card.emit(card)

func _on_area_2d_mouse_exited():
	self.scale = Vector2(3,3)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		clicked_card.emit(card)
