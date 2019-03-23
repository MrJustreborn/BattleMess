extends "res://entities/base_entity.gd"

func _ready():
	pass

func get_posible_moves(controller):
	var cell = parent.cell;
	var isWhite = parent.isWhite;
	
	var r = []
	
	var rup = get_right_up(controller, cell, isWhite)
	var lup = get_left_up(controller, cell, isWhite)
	
	var rd = get_right_down(controller, cell, isWhite)
	var ld = get_left_down(controller, cell, isWhite)
	
	for a in rup:
		r.append(a);
	for a in lup:
		r.append(a);
	for a in rd:
		r.append(a);
	for a in ld:
		r.append(a);
	
	return r;

func get_right_up(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_right_up(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_left_up(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_left_up(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_right_down(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_right_down(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_left_down(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_left_down(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;

