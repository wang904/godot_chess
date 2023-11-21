extends TileMap

enum Cells{
	GREEN = 0,WHITE = 1,YELLOW = 2
}
#上一次被更换的
var last_clicked_cell : Vector2i = Vector2i(-1,-1)
var last_clicked_col : Cells = Cells.WHITE
var promotion : Control = null


func _ready():
	promotion = get_tree().get_root().get_node("chessboard").get_node("promotion")
#高亮选中的格子
func tileChangeColor_focus():
	var clicked_cell : Vector2i = local_to_map(get_local_mouse_position())
	if last_clicked_cell != Vector2i(-1,-1):
		set_cell(0,last_clicked_cell,last_clicked_col,Vector2i(0,0))
	last_clicked_cell = clicked_cell
	#把上一次点击的颜色记录
	last_clicked_col = get_cell_source_id(0,clicked_cell)
	set_cell(0,clicked_cell,Cells.YELLOW,Vector2i(0,0))

func _input(event):
	if event is InputEventMouseButton:
		#左键按下
		if event.button_index == 1 and event.pressed and not promotion.visible:
			tileChangeColor_focus()
		