extends "res://entities/base_entity.gd"

func _ready():
	pass

func get_posible_moves(controller):
	var cell = parent.cell;
	var isWhite = parent.isWhite;
	
	var up = check_up(controller, cell, 1, isWhite);
	var down = check_down(controller, cell, 1, isWhite);
	
	var left = check_left(controller, cell, 1, isWhite);
	var right = check_right(controller, cell, 1, isWhite);
	
	var lup = check_left_up(controller, cell, 1, isWhite);
	var rup = check_right_up(controller, cell, 1, isWhite);
	
	var ldown = check_left_down(controller, cell, 1, isWhite);
	var rdown = check_right_down(controller, cell, 1, isWhite);
	
	
	var r = []
	
	if up.type != GridType.WALL:
		r.append(up)
	if down.type != GridType.WALL:
		r.append(down)
	
	if left.type != GridType.WALL:
		r.append(left)
	if right.type != GridType.WALL:
		r.append(right)
	
	if lup.type != GridType.WALL:
		r.append(lup)
	if rup.type != GridType.WALL:
		r.append(rup)
	
	if ldown.type != GridType.WALL:
		r.append(ldown)
	if rdown.type != GridType.WALL:
		r.append(rdown)
	
	return r;
