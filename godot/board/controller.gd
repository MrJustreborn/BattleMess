class_name ChessBoardController
extends Node

const clean_board = [
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null]
];

var cur_board = clean_board.duplicate(true);
var next_board = clean_board.duplicate(true);

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		next_board = clean_board.duplicate(true);
		get_tree().call_group("white", "cancel_next_move");
		get_tree().call_group("white", "predict_next_move");
	if Input.is_action_just_pressed("ui_cancel"):
		next_board = clean_board.duplicate(true);
		get_tree().call_group("white", "cancel_next_move");
	if Input.is_action_just_pressed("ui_accept"):
		next_board = clean_board.duplicate(true);
		get_tree().call_group("white", "perform_next_move");

func add_predict_move(cell: Vector2, what: Node):
	assert(next_board[cell.x][cell.y] == null)
	next_board[cell.x][cell.y] = what

func remove_predict_move(cell: Vector2):
	assert(next_board[cell.x][cell.y] != null)
	next_board[cell.x][cell.y] = null

func remove_node(cell):
	assert(cur_board[cell.x][cell.y] != null)
	cur_board[cell.x][cell.y] = null

func add_node(cell: Vector2, what: Node):
	assert(cur_board[cell.x][cell.y] == null)
	cur_board[cell.x][cell.y] = what

func get_cell_item(cell: Vector2):
	var tmp = cur_board[cell.x][cell.y];
	if tmp == null:
		tmp = next_board[cell.x][cell.y];
	return tmp;

