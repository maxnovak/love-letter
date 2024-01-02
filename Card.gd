extends Node

signal hover_over_card(card_type)
signal clicked_card

const pickedSuit = "Clubs"
const hiddenCard = preload("res://assets/Cards/Backs/back_0.png")

## Card type determines what happens when this card is played.
@export
var card_type: String = ""

## Sets visibility of the card for the player
@export
var visible: bool = false: set = _set_visible, get = _get_visible
func _set_visible(new_value):
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": Global.cardBreakdown[card_type].assetName})
	var visibleCard = load(path)
	if new_value == true:
		$Sprite2D.texture = visibleCard
	else:
		$Sprite2D.texture = hiddenCard
	visible = new_value
func _get_visible():
	return visible

func setup(type: String, visibility: bool, noHover: bool = false):
	card_type = type
	visible = visibility
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": Global.cardBreakdown[card_type].assetName})
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
	hover_over_card.emit(card_type)

func _on_area_2d_mouse_exited():
	self.scale = Vector2(3,3)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		clicked_card.emit(card_type)
