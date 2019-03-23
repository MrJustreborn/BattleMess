extends "res://entities/base_entity.gd"

func _ready():
	pass

func get_posible_moves(controller):
	var cell = parent.cell;
	var isWhite = parent.isWhite;
	
	var cup = Vector2(cell.x, cell.y - 1)
	var cdown = Vector2(cell.x, cell.y + 1)
	var cleft = Vector2(cell.x - 1, cell.y)
	var cright = Vector2(cell.x + 1, cell.y)
	
	var left1 = check_left(controller, cup, 2, isWhite);
	var right1 = check_right(controller, cup, 2, isWhite);
	var left2 = check_left(controller, cdown, 2, isWhite);
	var right2 = check_right(controller, cdown, 2, isWhite);
	
	var up1 = check_up(controller, cleft, 2, isWhite);
	var down1 = check_down(controller, cleft, 2, isWhite);
	var up2 = check_up(controller, cright, 2, isWhite);
	var down2 = check_down(controller, cright, 2, isWhite);
	
	var r = []
	
	r.append(left1)
	r.append(right1)
	r.append(left2)
	r.append(right2)
	r.append(up1)
	r.append(down1)
	r.append(up2)
	r.append(down2)
	
	return r;
