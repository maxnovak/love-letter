extends Node2D

var deck := []
var turn = 0
var turnOrder := []
var dealCard = false

const CardScene = preload("res://card.tscn")
const OpponentScene = preload("res://opponent.tscn")

signal chooseOpponent

# Called when the node enters the scene tree for the first time.
func _ready():
	var opponent = OpponentScene.instantiate()
	opponent.position = Vector2(640, 0)
	opponent.name = "Opponent1"
	opponent.clicked.connect(_chooseOpponent.bind(opponent))
	add_child(opponent)
	turnOrder = [$PlayersHand, opponent]
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
	for player in turnOrder:
		var card = deck.pop_front()
		player.add_child(card)
		if player == $PlayersHand:
			card._set_visible(true)

	for card in $PlayersHand.get_children():
		card.hover_over_card.connect($HUD._on_players_hand_text)
		card.clicked_card.connect(on_Card_click.bind(card))

func deal_card(player):
	dealCard = false
	var newCard = deck.pop_front()

	var card = player.find_child("Card*", true, false)
	if card != null:
		card.position = Vector2(-50,0)
		newCard.position = Vector2(50,0)

	if player == $PlayersHand:
		newCard._set_visible(true)
	player.add_child(newCard, true)

	if player == $PlayersHand:
		newCard.hover_over_card.connect($HUD._on_players_hand_text)
		newCard.clicked_card.connect(on_Card_click.bind(newCard))

func on_Card_click(cardType, cardToRemove):
	if turnOrder[turn % turnOrder.size()] != $PlayersHand:
		return

	var otherCard
	for card in $PlayersHand.get_children():
		if card != cardToRemove:
			otherCard = card

	if cardType == "princess":
		turnOrder = turnOrder.filter(func(player): return player != $PlayersHand)

	if otherCard._get_card() == "countess" && \
	(cardType == "prince" || cardType == "king"):
		$HUD.show_instruction("Cannot play card")
		return

	otherCard.position = Vector2(0,0)
	await animate_card_play(cardToRemove)

	if cardType == "king":
		$HUD.show_instruction("Choose opponent")
		var opponent = await chooseOpponent
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		opponentsCard.clicked_card.connect(on_Card_click.bind(opponentsCard))
		var playersCardToSwap = $PlayersHand.find_child("Card*", true, false)
		playersCardToSwap._set_visible(false)
		playersCardToSwap.hover_over_card.disconnect($HUD._on_players_hand_text)
		opponentsCard.get_parent().remove_child(opponentsCard)
		$PlayersHand.add_child(opponentsCard)
		playersCardToSwap.get_parent().remove_child(playersCardToSwap)
		opponent.add_child(playersCardToSwap)
		$HUD.hide_instruction()

	if cardType == "prince":
		$HUD.show_instruction("Choose opponent")
		var opponent = await chooseOpponent
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		await animate_card_play(opponentsCard)
		deal_card(opponent)

	if cardType == "baron":
		$HUD.show_instruction("Choose opponent")
		var opponent = await chooseOpponent
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		var playersComparing = [$PlayersHand, opponent]
		var winner = Global.findWinner(playersComparing)
		$HUD.hide_instruction()
		if winner == null:
			$ViewCardTimer.start()
		else:
			playersComparing = playersComparing.filter(func(player): return player != winner)
			turnOrder = turnOrder.filter(func(player): return !playersComparing.has(player))

	if cardType == "priest":
		$HUD.show_instruction("Choose opponent")
		var opponent = await chooseOpponent
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		$HUD.hide_instruction()
		$ViewCardTimer.start()

	next_player()

func next_player():
	if !$ViewCardTimer.is_stopped():
		await $ViewCardTimer.timeout
	turn += 1
	dealCard = true

func _process(_delta):
	var current_player = turnOrder[turn % turnOrder.size()]

	if deck.size() <= 1 && current_player.find_children("Card*", "Node2D", true, false).size() == 1:
		var winner = Global.findWinner(turnOrder)
		print(winner.name)
		return
	elif turnOrder.size() <= 1:
		print(turnOrder[0].name)
		return

	if dealCard == true:
		deal_card(turnOrder[turn % turnOrder.size()])
		if current_player != $PlayersHand:
			# Bad AI for Opponent
			var cards = current_player.find_children("Card*", "Node2D", true, false)
			var playedCard = cards[0]
			cards[1].position = Vector2(0,0)

			playedCard._set_visible(true)
			playedCard.hover_over_card.connect($HUD._on_players_hand_text)
			await animate_card_play(playedCard)
			next_player()


func animate_card_play(card):
	var newXCoord = $PlayedCards.get_children().size()*20
	var position_end = $PlayedCards.get_global_position()
	position_end.x += newXCoord
	var duration_in_seconds = 1.0
	var tween = create_tween()
	tween.tween_property(card, "global_position", position_end, duration_in_seconds)
	tween.play()
	await tween.finished # wait until move animation is complete
	card.get_parent().remove_child(card)
	$PlayedCards.add_child(card)
	card.position = Vector2(newXCoord,0) # reset local position after re-parenting

func _chooseOpponent(selected):
	chooseOpponent.emit(selected)
