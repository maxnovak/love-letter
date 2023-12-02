extends Node2D

var deck := []
var turn = 0
var turnOrder := []

const CardScene = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	turnOrder = [$PlayersHand, $OpponentHand]
	randomize()
	create_deck()
	deck.shuffle()
	deal_starting_cards()
	deal_card(turnOrder[turn])

func create_deck():
	for cardType in Global.cardBreakdown:
		for i in Global.cardBreakdown[cardType].count:
			var card := CardScene.instantiate()
			card.setup(Global.cardBreakdown[cardType].cardName, false)
			deck.append(card)

func deal_starting_cards():
	var playersCard = deck.pop_front()
	playersCard.position = Vector2(-50,0)
	playersCard._set_visible(true)
	$PlayersHand.add_child(playersCard)

	var opponentsCard = deck.pop_front()
	$OpponentHand.add_child(opponentsCard)

	for card in $PlayersHand.get_children():
		card.hover_over_card.connect($PlayersHand._on_Card_hover_over_card.bind(card))
		card.clicked_card.connect(on_Card_click.bind(card))

func deal_card(player):
	if deck.size() == 1:
		return
	var currentCard = player.get_child(0)
	currentCard.position = Vector2(-50,0)

	var newCard = deck.pop_front()
	newCard.position = Vector2(50,0)
	if player == $PlayersHand:
		newCard._set_visible(true)
	player.add_child(newCard)

	if player == $PlayersHand:
		newCard.hover_over_card.connect($PlayersHand._on_Card_hover_over_card.bind(newCard))
		newCard.clicked_card.connect(on_Card_click.bind(newCard))

func on_Card_click(cardType, cardToRemove):
	if turnOrder[turn % turnOrder.size()] != $PlayersHand:
		return
	if cardType == "priest":
		$OpponentHand.get_child(0)._set_visible(true)

	for card in $PlayersHand.get_children():
		if card != cardToRemove:
			card.position = Vector2(0,0)

	cardToRemove.position = Vector2(0,turn*20)
	$PlayersHand.remove_child(cardToRemove)
	$PlayedCards.add_child(cardToRemove)

	next_player()

func next_player():
	turn += 1
	deal_card(turnOrder[turn % turnOrder.size()])

func _process(delta):
	var current_player = turnOrder[turn % turnOrder.size()]
	if current_player.get_child_count() == 1:
		deal_card(turnOrder[turn % turnOrder.size()])

func _on_opponent_hand_play_card(playedCard):
	var activeOpponent = turnOrder[turn % turnOrder.size()]
	for card in activeOpponent.get_children():
		if card != playedCard:
			card.position = Vector2(0,0)

	playedCard.position = Vector2(0,turn*20)
	playedCard._set_visible(true)

	activeOpponent.remove_child(playedCard)
	$PlayedCards.add_child(playedCard)

	next_player()
