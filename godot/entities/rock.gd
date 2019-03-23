extends "res://entities/base_entity.gd"

func _ready():
	pass

func get_posible_moves(controller):
	var cell = parent.cell;
	var isWhite = parent.isWhite;
	
	var r = []
	
	var right = get_right(controller, cell, isWhite)
	var left = get_left(controller, cell, isWhite)
	
	var up = get_up(controller, cell, isWhite)
	var down = get_down(controller, cell, isWhite)
	
	for a in right:
		r.append(a);
	for a in left:
		r.append(a);
	for a in up:
		r.append(a);
	for a in down:
		r.append(a);
	
	return r;

func get_right(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_right(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_left(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_left(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_up(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_up(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;
func get_down(controller, cell, isWhite):
	var all = [];
	for i in range(1,8):
		var check = check_down(controller, cell, i, isWhite)
		if check.type == GridType.FREE:
			all.append(check);
		elif check.type == GridType.FRIEND || check.type == GridType.OPPONENT:
			all.append(check)
			return all;
		else:
			return all;
	return all;

