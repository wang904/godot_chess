extends Button

var piece : TileMap = null


func _on_pressed():
	var moves : Array = piece.moves
	if moves.size() > 0:
		if moves.back()[0] != Vector2i(-1,-1):
			piece.set_cell(0,moves.back()[1],moves.back()[3],Vector2i(0,0))
			piece.set_cell(0,moves.back()[0],moves.back()[2],Vector2i(0,0))
		else:
			piece.set_cell(0,moves.back()[2],moves.back()[6],Vector2i(0,0))
			piece.set_cell(0,moves.back()[1],moves.back()[5],Vector2i(0,0))
			piece.set_cell(0,moves.back()[3])
			piece.set_cell(0,moves.back()[4])
		moves.pop_back()
		piece.player = not piece.player

func _ready():
	piece = get_tree().get_root().get_node("chessboard").get_node("pieces")

