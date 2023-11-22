extends Node

signal hover_over_card

const cardBreakdown := {
	"princess": "Clubs_card_08",
	"countess": "Clubs_card_07",
	"king": "Clubs_card_06",
	"prince": "Clubs_card_05",
	"handmaid": "Clubs_card_04",
	"baron": "Clubs_card_03",
	"priest": "Clubs_card_02",
	"guard": "Clubs_card_01",
}

var rng = RandomNumberGenerator.new()
var pickedSuit = "Clubs"
var card: String = "": set = _set_card, get = _get_card
func _set_card(new_value):
	card = new_value
func _get_card():
		return card

func setup(cardType: String):
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": cardBreakdown[cardType]})
	var texture = load(path)
	
	$Sprite2D.texture = texture
	card = cardType

func _on_area_2d_mouse_entered():
	hover_over_card.emit(true)

func _on_area_2d_mouse_exited():
	hover_over_card.emit(false)
