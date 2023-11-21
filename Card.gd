extends Node

var rng = RandomNumberGenerator.new()
var pickedSuit = "Clubs"

func setup(cardType: String):
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": cardType})
	var texture = load(path)
	
	$Sprite2D.texture = texture
