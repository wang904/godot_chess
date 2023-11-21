extends Control

var piece = null

func _ready():
	piece = get_tree().get_root().get_node("chessboard").get_node("pieces")

func _on_bishop_pressed():
	piece.promot("bishop")

func _on_rock_pressed():
	piece.promot("rock")

func _on_knight_pressed():
	piece.promot("knight")

func _on_queen_pressed():
	piece.promot("queen")
