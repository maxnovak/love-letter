extends Node2D

var deck := []
var cardBreakdown := {
	"princess": {"count": 1, "cardName": "princess", "value": 8},
	"countess": {"count": 1, "cardName": "countess", "value": 7},
	"king": {"count": 1, "cardName": "king", "value": 6},
	"prince": {"count": 2, "cardName": "prince", "value": 5},
	"handmaid": {"count": 2, "cardName": "handmaid", "value": 4},
	"baron": {"count": 2, "cardName": "baron", "value": 3},
	"priest": {"count": 2, "cardName": "priest", "value": 2},
	"guard": {"count": 5, "cardName": "guard", "value": 1},
}

const CardScene = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	create_deck()
	deck.shuffle()
	deal_cards()

func create_deck():
	for cardType in cardBreakdown:
		for i in cardBreakdown[cardType].count:
			var card := CardScene.instantiate()
			card.setup(cardBreakdown[cardType].cardName, false)
			deck.append(card)

func deal_cards():
	var playersCard = deck.pop_front()
	playersCard.position = Vector2(-50,0)
	playersCard._set_visible(true)
	$PlayersHand.add_child(playersCard)

	var playersCard2 = deck.pop_front()
	playersCard2.position = Vector2(50,0)
	playersCard2._set_visible(true)
	$PlayersHand.add_child(playersCard2)

	var opponentsCard = deck.pop_front()
	$OpponentHand.add_child(opponentsCard)

	for card in $PlayersHand.get_children():
		card.hover_over_card.connect($PlayersHand._on_Card_hover_over_card.bind(card))
	for card in $PlayersHand.get_children():
		card.clicked_card.connect($PlayersHand._on_Card_click)
