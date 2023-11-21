extends Node2D

var deck := []
var cardBreakdown := {
	"princess": {"count": 1, "cardName": "Clubs_card_08", "value": 8},
	"countess": {"count": 1, "cardName": "Clubs_card_07", "value": 7},
	"king": {"count": 1, "cardName": "Clubs_card_06", "value": 6},
	"prince": {"count": 2, "cardName": "Clubs_card_05", "value": 5},
	"handmaid": {"count": 2, "cardName": "Clubs_card_04", "value": 4},
	"baron": {"count": 2, "cardName": "Clubs_card_03", "value": 3},
	"priest": {"count": 2, "cardName": "Clubs_card_02", "value": 2},
	"guard": {"count": 5, "cardName": "Clubs_card_01", "value": 1},
}

const CardScene = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	create_deck()
	deck.shuffle()
	
	var playersCard = deck[0]
	var playersHand = get_tree().get_root().get_node("Table/PlayersHand")
	
	playersHand.add_child(playersCard)
	

func create_deck():
	for cardType in cardBreakdown:
		for i in cardBreakdown[cardType].count:
			var card := CardScene.instantiate()
			card.setup(cardBreakdown[cardType].cardName)
			deck.append(card)



func _on_hand_mouse_entered():
	var playersHand = get_tree().get_root().get_node("Table/PlayersHand")
	playersHand.scale = Vector2(1.5, 1.5)


func _on_hand_mouse_exited():
	var playersHand = get_tree().get_root().get_node("Table/PlayersHand")
	playersHand.scale = Vector2(1, 1)
