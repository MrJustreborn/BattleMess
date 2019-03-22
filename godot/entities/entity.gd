tool

extends Node2D

enum chess_type {
	pawn,
	king,
	queen,
	bishop,
	knight,
	rock
}

export(bool) var white = true setget setWhite;
export(chess_type) var type = chess_type.pawn setget setChessType;

var current_node: Node

func _ready():
	# set current_node
	setChessType(type);
	pass

func setChessType(t):
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
	white = value;

func showType(what: String):
	var c = $white.get_children()
	
	for a in c:
		a.visible = false;
	$white.get_node(what).visible = true;
	
	c = $black.get_children()
	
	for a in c:
		a.visible = false;
	$black.get_node(what).visible = true;
	
	if white:
		current_node = $white.get_node(what);
	else:
		current_node = $black.get_node(what);
