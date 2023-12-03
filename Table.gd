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
	await animate_card_play(cardToRemove)

	next_player()

func next_player():
	turn += 1

func _process(delta):
	var current_player = turnOrder[turn % turnOrder.size()]
	if current_player.get_child_count() == 1:
		deal_card(turnOrder[turn % turnOrder.size()])
		if current_player != $PlayersHand:
			var cards = current_player.get_children()
			var playedCard = cards[0]
			cards[1].position = Vector2(0,0)

			playedCard._set_visible(true)
			await animate_card_play(playedCard)
			next_player()


func animate_card_play(card):
	var position_end = $PlayedCards.get_global_position()
	position_end.y += turn*20
	var duration_in_seconds = 1.0
	var tween = create_tween()
	tween.tween_property(card, "global_position", position_end, duration_in_seconds)
	tween.play()
	await tween.finished # wait until move animation is complete
	card.get_parent().remove_child(card)
	$PlayedCards.add_child(card)
	card.position = Vector2(0,turn*20) # reset local position after re-parenting
