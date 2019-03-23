extends "res://entities/base_entity.gd"

onready var parent = get_node("../..");

func _ready():
	pass

func get_posible_moves(controller):
	var cell = parent.cell;
	var isWhite = parent.isWhite;
	var up = check_up(controller, cell, 1, isWhite);
	var lup = check_left_up(controller, cell, 1, isWhite);
	var rup = check_right_up(controller, cell, 1, isWhite);
	
	var up2 = null
	if cell.y == 1 || cell.y == 6:
		up2 = check_up(controller, cell, 2, isWhite);
	
	var r = []
	if up.type == GridType.FREE:
		r.append(up)
	
	if up2 != null && up.type == GridType.FREE:
		r.append(up2)
	
	if lup.type == GridType.FRIEND || lup.type == GridType.OPPONENT:
		r.append(lup)
	
	if rup.type == GridType.FRIEND || rup.type == GridType.OPPONENT:
		r.append(rup)
	
	return r;
