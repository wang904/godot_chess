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

var promotion : Control = null
#true -> white false -> black
var player : bool = true
var promoted_position : Vector2i = Vector2i.ZERO

var moves = []

func _ready():
	promotion = get_tree().get_root().get_node("chessboard").get_node("promotion")

func promot(type):
	promotion.visible = false
	if get_cell_source_id(0,promoted_position) < 6:
		match type:
			"queen":
				set_cell(0,promoted_position,Cells.BLACK_QUEEN,Vector2i(0,0))
			"knight":
				set_cell(0,promoted_position,Cells.BLACK_KNIGHT,Vector2i(0,0))
			"bishop":
				set_cell(0,promoted_position,Cells.BLACK_BISHOP,Vector2i(0,0))
			"rock":
				set_cell(0,promoted_position,Cells.BLACK_ROCK,Vector2i(0,0))
	else:
		match type:
			"queen":
				set_cell(0,promoted_position,Cells.WHITE_QUEEN,Vector2i(0,0))
			"knight":
				set_cell(0,promoted_position,Cells.WHITE_KNIGHT,Vector2i(0,0))
			"bishop":
				set_cell(0,promoted_position,Cells.WHITE_BISHOP,Vector2i(0,0))
			"rock":
				set_cell(0,promoted_position,Cells.WHITE_ROCK,Vector2i(0,0))
	player = not player

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
		var temp = Vector2i(clicked_cell.x,clicked_cell.y + 1)
		var temp1 = Vector2i(clicked_cell.x,clicked_cell.y - 1)
		if has_piece(temp) and moves.back()[1] == temp and moves.back()[0] == temp1 and moves.back()[2] == Cells.BLACK_PAWN:
			set_cell(0,temp)
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
		#吃过路兵
		var temp = Vector2i(clicked_cell.x,clicked_cell.y - 1)
		var temp1 = Vector2i(clicked_cell.x,clicked_cell.y + 1)
		if has_piece(temp) and moves.back()[1] == temp and moves.back()[0] == temp1 and moves.back()[2] == Cells.WHITE_PAWN:
			set_cell(0,temp)
			return true
	return false


func check_knight(clicked_cell) -> bool:
	var deltaX = [2, 1,-1,-2,-2,-1, 1, 2]
	var deltaY = [1, 2, 2, 1,-1,-2,-2,-1];
	for i in range(8):
		if Vector2i(last_piece_position.x + deltaX[i],last_piece_position.y + deltaY[i]) == clicked_cell:
			return true
	return false

func check_rock(clicked_cell) -> bool:
	if last_piece_position.x == clicked_cell.x:
		for i in range(min(last_piece_position.y,clicked_cell.y) + 1,max(last_piece_position.y,clicked_cell.y)):
			if has_piece(Vector2i(clicked_cell.x,i)):
				return false
		return true
	elif last_piece_position.y == clicked_cell.y:
		for i in range(min(last_piece_position.x,clicked_cell.x) + 1,max(last_piece_position.x,clicked_cell.x)):
			if has_piece(Vector2i(i,clicked_cell.y)):
				return false
		return true	
	return false

func check_bishop(clicked_cell) -> bool:
	var x = last_piece_position.x
	var y = last_piece_position.y
	while x <= 7 and y <= 7:
		x += 1
		y += 1
		if x == clicked_cell.x and y == clicked_cell.y:
			return true
		if has_piece(Vector2(x,y)):
			break
	x = last_piece_position.x
	y = last_piece_position.y
	while x >= 0 and y >= 0:
		x -= 1
		y -= 1
		if x == clicked_cell.x and y == clicked_cell.y:
			return true
		if has_piece(Vector2(x,y)):
			break
	x = last_piece_position.x
	y = last_piece_position.y
	while x <= 7 and y >= 0:
		x += 1
		y -= 1
		if x == clicked_cell.x and y == clicked_cell.y:
			return true
		if has_piece(Vector2(x,y)):
			break
	x = last_piece_position.x
	y = last_piece_position.y
	while x >= 0 and y <= 7:
		x -= 1
		y += 1
		if x == clicked_cell.x and y == clicked_cell.y:
			return true
		if has_piece(Vector2(x,y)):
			break
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
		Cells.WHITE_ROCK,Cells.BLACK_ROCK:
			if not check_rock(clicked_cell):
				return false
		Cells.WHITE_BISHOP,Cells.BLACK_BISHOP:
			if not check_bishop(clicked_cell):
				return false
		Cells.WHITE_QUEEN,Cells.BLACK_QUEEN:
			if not check_bishop(clicked_cell) and not check_rock(clicked_cell):
				return false
	return true

func check_promoted(clicked_cell):
	if (player and clicked_cell.y == 0 and get_cell_source_id(0,clicked_cell) == Cells.WHITE_PAWN) or (not player and clicked_cell.y == 7 and get_cell_source_id(0,clicked_cell) == Cells.BLACK_PAWN):
		promotion.visible = true
		promoted_position = clicked_cell

#返回值代表移动是否成功
func make_move() -> bool:
	var clicked_cell : Vector2i = local_to_map(get_local_mouse_position())
	var cell_id : Cells = get_cell_source_id(0,clicked_cell)
	var ok : bool = false
	if can_move(clicked_cell):
		set_cell(0,clicked_cell,last_piece_col,Vector2i(0,0))
		set_cell(0,last_piece_position)
		check_promoted(clicked_cell)
		moves.append([last_piece_position,clicked_cell,last_piece_col,cell_id])
		ok = true
		last_piece_col = Cells.EMPTY
		last_piece_position = Vector2i(-1,-1)
	return ok
		
func handle_left_button():
	if last_piece_col == Cells.EMPTY and not promotion.visible:
		select_piece()
	elif make_move():
		player = not player

func _input(event):
	if event is InputEventMouseButton:
		#左键按下
		if event.button_index == 1 and event.pressed:
			handle_left_button()
