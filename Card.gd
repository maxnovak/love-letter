extends Node

signal hover_over_card

var rng = RandomNumberGenerator.new()
var pickedSuit = "Clubs"

func setup(cardType: String):
	var path = "res://assets/Cards/Clubs/{cardType}.png".format({"cardType": cardType})
	var texture = load(path)
	
	$Sprite2D.texture = texture

func _on_area_2d_mouse_entered():
	hover_over_card.emit(true)

func _on_area_2d_mouse_exited():
	hover_over_card.emit(false)
