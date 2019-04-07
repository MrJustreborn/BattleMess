tool
extends EditorScript#Node

var lock: Mutex = Mutex.new();

var current_field = {}
var future_field = {}

var entity = preload("res://test/test_entity.gd")

func _run():
	print("\nrun ...");
	_prefill();

func _ready():
	pass;

func is_cell_free(cell: Vector2) -> bool:
	return false;

func get_cell_entity(cell: Vector2) -> Node:
	return null;

func request_move(cell: Vector2, who: Node) -> bool:
	return false;

func _prefill():
	for y in range(8):
		for x in range(8):
			current_field[Vector2(x,y)] = [];
	
	#black
	for y in range(2):
		for x in range(8):
			current_field[Vector2(x,y)].append(entity.new());
	
	#white
	for y in range(6,8):
		for x in range(8):
			current_field[Vector2(x,y)].append(entity.new());
	_pretty_print();

func _pretty_print():
	print("[TYPE][NUMBER_PLAYER][AI/REAL = a/r]")
	print("=  =  =  =  =  =  =  =  =  =")
	for y in range(8):
		var t = "";
		for x in range(8):
			if current_field[Vector2(x,y)].size() > 0:
				t += "_" + str(current_field[Vector2(x,y)].size()) + "a";
			else:
				t += " · ";
		print("= " + t + " =")
	print("=  =  =  =  =  =  =  =  =  =")
