extends Node

const cardBreakdown := {
	"princess": {
		"assetName": "Clubs_card_08",
		"cardName": "princess",
		"count": 1,
		"description": "If you discard this card, you are out of the round.",
		"value": 8,
	},
	"countess": {
		"assetName": "Clubs_card_07",
		"cardName": "countess",
		"count": 1,
		"description": "If you have this card and the King (6) or Prince (5).",
		"value": 7,
	},
	"king": {
		"assetName": "Clubs_card_06",
		"cardName": "king",
		"description": "Trade hands with another player of your choice.",
		"count": 1,
		"value": 6,
	},
	"prince": {
		"assetName": "Clubs_card_05",
		"cardName": "prince",
		"count": 2,
		"description": "Choose any player (including yourself) to discard their hand and draw a new card.",
		"value": 5,
	},
	"handmaid": {
		"assetName": "Clubs_card_04",
		"cardName": "handmaid",
		"count": 2,
		"description": "Until next turn, ignore all effects from other players' cards.",
		"value": 4,
	},
	"baron": {
		"assetName": "Clubs_card_03",
		"cardName": "baron", 
		"count": 2,
		"description": "You and another player secretly compare hands. The player with the lower value is out of the round.",
		"value": 3,
	},
	"priest": {
		"assetName": "Clubs_card_02",
		"cardName": "priest",
		"count": 2,
		"description": "Look at another player's hand.",
		"value": 2,
	},
	"guard": {
		"assetName": "Clubs_card_01",
		"cardName": "guard",
		"count": 5,
		"description": "Name a non-Guard (1) card and choose another player. If that player has that card, they are out of the round.",
		"value": 1,
	},
}

func findWinner(players) -> Node2D:
	var playersValues =[]
	for player in players:
		var card = player.find_child("Card*", true, false)
		card._set_visible(true)
		playersValues.append(Global.cardBreakdown[card._get_card()].value)
	# if the max and min are the same tis a tie
	if playersValues[0] == playersValues.max() && playersValues[0] == playersValues.min():
		return null
	else:
		return players[playersValues.find(playersValues.max())]
