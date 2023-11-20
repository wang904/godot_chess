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
	#6是白棋和黑棋的交界处
	if (player and cell_id >= 6) or (not player and cell_id < 6):
		last_piece_position = clicked_cell
		last_piece_col = cell_id

func check_king(clicked_cell) -> bool:
	var dis = clicked_cell - last_piece_position
	return  abs(dis.x) <= 1 and abs(dis.y) <= 1 

func has_piece(position):
	return get_cell_source_id(0,position) != -1

func check_white_pawn(clicked_cell) -> bool:
	if last_piece_position.x == clicked_cell.x:
		if last_piece_position.y == 6 and clicked_cell.y - last_piece_position.y == -2 and !has_piece(clicked_cell) and !has_piece(Vector2i(clicked_cell.x,clicked_cell.y + 1)):
			return true
		if  clicked_cell.y - last_piece_position.y == -1 and !has_piece(clicked_cell):
			return true
	if abs(last_piece_position.x - clicked_cell.x) == 1 and clicked_cell.y - last_piece_position.y == -1:
		#这里不用判断吃自己子因为已经在can_move里面判断了
		if has_piece(clicked_cell):
			return true
	return false

func check_black_pawn(clicked_cell) -> bool:
	if last_piece_position.x == clicked_cell.x:
		if last_piece_position.y == 1 and clicked_cell.y - last_piece_position.y == 2 and !has_piece(clicked_cell) and !has_piece(Vector2i(clicked_cell.x,clicked_cell.y - 1)):
			return true
		if  clicked_cell.y - last_piece_position.y == 1 and !has_piece(clicked_cell):
			return true
	if abs(last_piece_position.x - clicked_cell.x) == 1 and clicked_cell.y - last_piece_position.y == 1:
		#这里不用判断吃自己子因为已经在can_move里面判断了
		if has_piece(clicked_cell):
			return true
	return false


func check_knight(clicked_cell) -> bool:
	var deltaX = [2, 1,-1,-2,-2,-1, 1, 2]
	var deltaY = [1, 2, 2, 1,-1,-2,-2,-1];
	for i in range(8):
		print(deltaX[i]," ",deltaY[i])
		if Vector2i(last_piece_position.x + deltaX[i],last_piece_position.y + deltaY[i]) == clicked_cell:
			return true
	return false

#是否可以移动
func can_move(clicked_cell) -> bool:
	var cell_id : Cells = get_cell_source_id(0,clicked_cell)
	#判断不能吃自己的子，不能不移动
	if clicked_cell == last_piece_position:
		return false
	if (player and cell_id >= 6) or (not player and cell_id < 6 and cell_id != -1):
		last_piece_position = clicked_cell
		last_piece_col = cell_id
		return false
	match last_piece_col:
		Cells.WHITE_KING,Cells.BLACK_KING:
			if not check_king(clicked_cell):
				return false
		Cells.WHITE_PAWN:
			if not check_white_pawn(clicked_cell):
				return false
		Cells.BLACK_PAWN:
			if not check_black_pawn(clicked_cell):
				return false
		Cells.WHITE_KNIGHT,Cells.BLACK_KNIGHT:
			if not check_knight(clicked_cell):
				return false
	return true

#返回值代表移动是否成功
func make_move() -> bool:
	var clicked_cell : Vector2i = local_to_map(get_local_mouse_position())
	var ok : bool = false
	if can_move(clicked_cell):
		set_cell(0,clicked_cell,last_piece_col,Vector2i(0,0))
		set_cell(0,last_piece_position)
		ok = true
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
