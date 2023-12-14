extends Node2D

var deck := []
var turn = 0
var turnOrder := []
var dealCard = false

const CardScene = preload("res://card.tscn")
const OpponentScene = preload("res://opponent.tscn")

signal chooseOpponent
signal choosePlayer
signal chooseCard

# Called when the node enters the scene tree for the first time.
func setup(numberOfPlayers: int):
	$PlayersHand.clicked.connect(_choosePlayer.bind($PlayersHand))
	turnOrder = [$PlayersHand]
	Global.playerNames.shuffle()
	for i in range(numberOfPlayers):
		var opponent = createOpponent(Global.playerNames[i], Global.seats[i])
		add_child(opponent)
		turnOrder.append(opponent)
	create_deck()
	deck.shuffle()
	deal_starting_cards()
	deal_card(turnOrder[turn])

func createOpponent(playerName: String, location: String) -> Node2D:
	var opponent = OpponentScene.instantiate()
	if location == "top":
		opponent.position = Vector2(640, 0)
	if location == "left":
		opponent.position = Vector2(25, 340)
		opponent.rotation_degrees = 90
	if location == "right":
		opponent.position = Vector2(1255, 340)
		opponent.rotation_degrees = -90
	opponent.name = playerName
	opponent._set_playerName(playerName)
	opponent.clicked.connect(_chooseOpponent.bind(opponent))
	opponent.clicked.connect(_choosePlayer.bind(opponent))
	return opponent

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

	for card in $PlayersHand.find_children("Card*", "Node2D", true, false):
		card.hover_over_card.connect($HUD._on_players_hand_text)
		card.clicked_card.connect(on_Card_click.bind(card))

func deal_card(player):
	dealCard = false
	var newCard = deck.pop_front()
	newCard.name = "Card%s" % turn

	var card = player.find_child("Card*", true, false)
	if card != null:
		card.position = Vector2(-50,0)
		newCard.position = Vector2(50,0)

	if player == $PlayersHand:
		newCard._set_visible(true)
		newCard.hover_over_card.connect($HUD._on_players_hand_text)
		newCard.clicked_card.connect(on_Card_click.bind(newCard))
	player.add_child(newCard, true)

func on_Card_click(cardType, cardToRemove):
	if turnOrder[turn % turnOrder.size()] != $PlayersHand:
		return
	if $PlayersHand.get_child_count() == 1:
		return

	var otherCard
	for card in $PlayersHand.find_children("Card*", "Node2D", true, false):
		if card != cardToRemove:
			otherCard = card

	if otherCard._get_card() == "countess" && \
	(cardType == "prince" || cardType == "king"):
		$HUD.show_instruction("Cannot play card")
		return

	otherCard.position = Vector2(0,0)
	await animate_card_play(cardToRemove)
	await resolveCard($PlayersHand, cardType)
	next_player()

func on_guard_select(cardType):
	chooseCard.emit(cardType)

func next_player():
	if !$ViewCardTimer.is_stopped():
		await $ViewCardTimer.timeout
		for player in turnOrder:
			if player != $PlayersHand:
				var playersCard = player.find_child("Card*", true, false)
				playersCard._set_visible(false)
	turn += 1
	dealCard = true

func _process(_delta):
	var current_player = turnOrder[turn % turnOrder.size()]

	if deck.size() <= 1 && current_player.find_children("Card*", "Node2D", true, false).size() == 1:
		var winner = Global.findWinner(turnOrder)
		if winner == $PlayersHand:
			$HUD.show_instruction("Winner is: You!")
		else:
			$HUD.show_instruction("Winner is: %s" % winner.name)
		return
	elif turnOrder.size() <= 1:
		var winner = turnOrder[0]
		if winner == $PlayersHand:
			$HUD.show_instruction("Winner is: You!")
		else:
			$HUD.show_instruction("Winner is: %s" % winner.name)
		return

	if dealCard == true:
		deal_card(turnOrder[turn % turnOrder.size()])
		if current_player != $PlayersHand:
			# Bad AI for Opponent
			var cards = current_player.find_children("Card*", "Node2D", true, false)
			var playedCard = cards[0]
			cards[1].position = Vector2(0,0)
			if cards[0]._get_card() == "princess":
				playedCard = cards[1]
				cards[0].position = Vector2(0,0)

			playedCard._set_visible(true)
			if !playedCard.hover_over_card.is_connected($HUD._on_players_hand_text):
				playedCard.hover_over_card.connect($HUD._on_players_hand_text)
			await animate_card_play(playedCard)
			resolveCard(current_player, playedCard._get_card())
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

func _choosePlayer(selected):
	choosePlayer.emit(selected)

func resolveCard(player, playedCard):
	if playedCard == "princess":
		var playersCard = player.find_child("Card*", true, false)
		playersCard._set_visible(true)
		await animate_card_play(playersCard)
		turnOrder = turnOrder.filter(func(play): return play != player)

	if playedCard == "king":
		var opponent
		if player == $PlayersHand:
			$HUD.show_instruction("Choose opponent")
			opponent = await chooseOpponent
		else:
			opponent = getRandomOpponent(player)
		var opponentsCard = opponent.find_child("Card*", true, false)
		if player == $PlayersHand:
			opponentsCard._set_visible(true)
			opponentsCard.clicked_card.connect(on_Card_click.bind(opponentsCard))
		var playersCardToSwap = player.find_child("Card*", true, false)
		if playersCardToSwap.hover_over_card.is_connected($HUD._on_players_hand_text):
			playersCardToSwap.hover_over_card.disconnect($HUD._on_players_hand_text)
		if opponent == $PlayersHand:
			playersCardToSwap._set_visible(true)
			playersCardToSwap.clicked_card.connect(on_Card_click.bind(playersCardToSwap))
		opponentsCard.get_parent().remove_child(opponentsCard)
		player.add_child(opponentsCard)
		playersCardToSwap.get_parent().remove_child(playersCardToSwap)
		opponent.add_child(playersCardToSwap)
		$HUD.hide_instruction()

	if playedCard == "prince":
		var opponent
		if player == $PlayersHand:
			$HUD.show_instruction("Choose player")
			opponent = await choosePlayer
		else:
			opponent = turnOrder[randi() % turnOrder.size()-1]
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		await animate_card_play(opponentsCard)
		if opponentsCard._get_card() == "princess":
			turnOrder = turnOrder.filter(func(opp): return opp != opponent)
		else:
			deal_card(opponent)

	if playedCard == "baron":
		var opponent
		if player == $PlayersHand:
			$HUD.show_instruction("Choose opponent")
			opponent = await chooseOpponent
		else:
			opponent = getRandomOpponent(player)
		var opponentsCard = opponent.find_child("Card*", true, false)
		var playersCard = player.find_child("Card*", true, false)
		if player == $PlayersHand:
			opponentsCard._set_visible(true)
		if opponent == $PlayersHand:
			playersCard._set_visible(true)
		var playersComparing = [player, opponent]
		var winner = Global.findWinner(playersComparing)
		$HUD.hide_instruction()
		if winner == null:
			$ViewCardTimer.start()
		else:
			var loser = playersComparing.find(!winner)
			turnOrder = turnOrder.filter(func(play): return play != playersComparing[loser])
			var losersCard = playersComparing[loser].find_child("Card*", true, false)
			losersCard._set_visible(true)
			await animate_card_play(losersCard)

	if playedCard == "priest":
		var opponent
		if player == $PlayersHand:
			$HUD.show_instruction("Choose opponent")
			opponent = await chooseOpponent
		else:
			return #Skipping AI logic mostly so no need to have them look at stuff
		var opponentsCard = opponent.find_child("Card*", true, false)
		opponentsCard._set_visible(true)
		$HUD.hide_instruction()
		$ViewCardTimer.start()

	if playedCard == "guard":
		var cardsToDisplay = {}
		for card in Global.cardBreakdown:
			if card == "guard":
				continue
			var choice := CardScene.instantiate()
			choice.setup(card, true, true)
			cardsToDisplay[card] = choice
		var opponent
		if player == $PlayersHand:
			$HUD.show_instruction("Choose opponent")
			opponent = await chooseOpponent
		else:
			opponent = getRandomOpponent(player)
		var v = cardsToDisplay.size()/2
		var placement = range(-v, v+1)
		var i = 0
		for card in cardsToDisplay.values():
			card.position = Vector2(placement[i]*150, 0)
			card.scale = Vector2(5,5)
			card.clicked_card.connect(on_guard_select)
			$GuardDisplay.add_child(card)
			i += 1
		var cardToGuess
		$HUD.show_instruction("Choose a card")
		cardToGuess = await chooseCard
		var opponentsCard = opponent.find_child("Card*", true, false)
		if cardToGuess == opponentsCard._get_card():
			opponentsCard._set_visible(true)
			await animate_card_play(opponentsCard)
			turnOrder = turnOrder.filter(func(opp): return opp != opponent)
		$HUD.hide_instruction()
		for n in $GuardDisplay.get_children():
			$GuardDisplay.remove_child(n)
			n.queue_free()

func getRandomOpponent(player):
	var opponents = turnOrder.filter(func(opp): return opp != player)
	opponents.shuffle()
	return opponents[0]
