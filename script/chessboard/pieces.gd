extends TileMap

enum Cells{
	EMPTY = -1,
	BLACK_BISHOP = 0,
	BLACK_KING = 1,
	BLACK_KNIGHT = 2,
	BLACK_PAWN = 3,
	BLACK_QUEEN = 4,
	BLACK_ROCK = 5,
	WHITE_BISHOP = 6,
	WHITE_KING = 7,
	WHITE_KNIGHT = 8,
	WHITE_PAWN = 9,
	WHITE_QUEEN = 10,
	WHITE_ROCK = 11
}

#上一次被更换的
var last_piece_position: Vector2i = Vector2i(-1,-1)
var last_piece_col : Cells = Cells.EMPTY

#true -> white false -> black
var player : bool = true

func select_piece():
	var clicked_cell : Vector2i = local_to_map(get_local_mouse_position())
	var cell_id : Cells = get_cell_source_id(0,clicked_cell)
 	#6 是白棋和黑棋的交界处
	if (player and cell_id >= 6) or (not player and cell_id < 6):
		last_piece_position = clicked_cell
		last_piece_col = cell_id

#是否可以移动
func can_move(_clicked_cell) -> bool:
	return true

#返回值代表移动是否成功
func make_move() -> bool:
	var clicked_cell : Vector2i = local_to_map(get_local_mouse_position())
	var ok : bool = false
	if can_move(clicked_cell):
		set_cell(0,clicked_cell,last_piece_col,Vector2i(0,0))
		set_cell(0,last_piece_position)
		ok = true
	if clicked_cell != last_piece_position:
		last_piece_col = Cells.EMPTY
		last_piece_position = Vector2i(-1,-1)
	return ok
		
func handle_left_button():
	if last_piece_col == Cells.EMPTY:
		select_piece()
	elif make_move():
		player = not player

func _input(event):
	if event is InputEventMouseButton:
		#左键按下
		if event.button_index == 1 and event.pressed:
			handle_left_button()