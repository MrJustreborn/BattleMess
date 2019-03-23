extends Node

enum GridType {
	FREE,
	FRIEND,
	OPPONENT,
	WALL
}

func _ready():
	pass

func check_left_up(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	from.x -= add;
	return check_up(controller, from, add, isWhite);
func check_right_up(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	from.x += add;
	return check_up(controller, from, add, isWhite);
func check_left_down(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	from.x -= add;
	return check_down(controller, from, add, isWhite);
func check_right_down(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	from.x += add;
	return check_down(controller, from, add, isWhite);

func check_up(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	if isWhite || (!isWhite && invert):
		from.y -= add;
	elif !isWhite || (isWhite && invert):
		from.y += add;
	
	if from.x < 0 || from.y < 0 || from.x > 7 || from.y > 7:
		return {"type": GridType.WALL, "pos": from};
	
	var item = controller.get_cell_item(from);
	
	if item == null:
		return {"type": GridType.FREE, "pos": from};
	
	if (item.isWhite && isWhite) || (!item.isWhite && !isWhite):
		return {"type": GridType.FRIEND, "pos": from};
	else:
		return {"type": GridType.OPPONENT, "pos": from};

func check_down(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool):
	return check_up(controller, from, add, isWhite, true);

func check_left(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool, invert: bool = false):
	if !invert:
		from.x -= add;
	elif invert:
		from.x += add;
	
	if from.x < 0 || from.y < 0 || from.x > 7 || from.y > 7:
		return {"type": GridType.WALL, "pos": from};
	
	var item = controller.get_cell_item(from);
	
	if item == null:
		return {"type": GridType.FREE, "pos": from};
	
	if (item.isWhite && isWhite) || (!item.isWhite && !isWhite):
		return {"type": GridType.FRIEND, "pos": from};
	else:
		return {"type": GridType.OPPONENT, "pos": from};

func check_right(controller: ChessBoardController, from: Vector2, add: int, isWhite: bool):
	return check_left(controller, from, add, isWhite, true);
