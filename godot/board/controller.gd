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

var cur_broad = clean_board;

func _ready():
	test()

func add_node(cell: Vector2, what: Node):
	assert(cur_broad[cell.x][cell.y] == null)
	cur_broad[cell.x][cell.y] = what

func get_cell_item(cell: Vector2):
	return cur_broad[cell.x][cell.y];

func test():
	print(cur_broad);
