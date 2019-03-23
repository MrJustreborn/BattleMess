tool
#class_name ChessEntity
extends Node2D

enum chess_type {
	pawn,
	king,
	queen,
	bishop,
	knight,
	rock
}

export(bool) var isWhite = true setget setWhite;
export(chess_type) var type = chess_type.pawn setget setChessType;
export(Vector2) var cell = Vector2(0, 0) setget setCell;

var controller: ChessBoardController;

var current_node: Node

var possible_moves = []

func _draw():
	if possible_moves:
		for move in possible_moves:
			var pos = move.pos
			var to = Vector2(pos.x - cell.x, pos.y - cell.y);
			
			if move.type == 0: #FREE
				draw_move(to, Color("#a0a0a0"));
			elif move.type == 1: #FRIEND
				draw_move(to, Color("#000fff"));
			elif move.type == 2: #OPPONENT
				draw_move(to, Color("#f0000f"));
			elif move.type == 3: #WALL
				pass
			

func draw_move(to: Vector2, color):
	draw_line(Vector2(), Vector2(to.x * 64, to.y * 64), color, 2, true)
	draw_circle(Vector2(to.x * 64, to.y * 64), 8, color);

func _ready():
	controller = get_node("../../..");
	controller.add_node(cell, self);
	
	if isWhite:
		add_to_group("white");
	else:
		add_to_group("black");
	
	# set current_node
	setChessType(type);
	
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if visible:
		possible_moves = get_posible_moves(controller);
		update()

func get_posible_moves(controller):
	return current_node.get_posible_moves(controller);




func setCell(newPos: Vector2):
	if newPos.x < 0 || newPos.y < 0 || newPos.x > 7 || newPos.y > 7:
		newPos = Vector2(0, 0);
	cell = newPos;
	position.x = 32 + 64 * cell.x
	position.y = 32 + 64 * cell.y
	

func setChessType(t):
	#update()
	match t:
		chess_type.pawn:
			showType("pawn");
		chess_type.king:
			showType("king");
		chess_type.queen:
			showType("queen");
		chess_type.bishop:
			showType("bishop");
		chess_type.knight:
			showType("knight");
		chess_type.rock:
			showType("rock");
	type = t;

func setWhite(value: bool):
	if value:
		$white.visible = true;
		$black.visible = false;
	else:
		$white.visible = false;
		$black.visible = true;
	isWhite = value;

func showType(what: String):
	var c = $white.get_children()
	
	for a in c:
		a.visible = false;
	$white.get_node(what).visible = true;
	
	c = $black.get_children()
	
	for a in c:
		a.visible = false;
	$black.get_node(what).visible = true;
	
	if isWhite:
		current_node = $white.get_node(what);
	else:
		current_node = $black.get_node(what);
