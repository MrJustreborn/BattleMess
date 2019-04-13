tool
extends Node

var lock: Mutex = Mutex.new();

var current_field = {}
var future_field = {}
var grid_size = Vector2(8, 8)

var entity = preload("res://test/test_entity.gd")

var test_entity = preload("res://test/testentity.tscn");

var grid: Node = null;

func _run():
	print("\nrun ...");
	_prefill();

func _ready():
	pass;

func is_cell_free(cell: Vector2) -> bool:
	assert(grid);
	
	print(grid.get_child(cell.y).get_child(cell.x).name);
	
	return false;

func get_cell_entity(cell: Vector2) -> Node:
	return null;

func request_move(cell: Vector2, who: Node) -> bool:
	return false;

func init_grid(grid: Node, entities: Node):
	self.grid = grid
	grid_size.y = grid.get_child_count();
	var children = grid.get_children();
	var x_size = 0;
	for c in children:
		if c.get_child_count() > x_size:
			x_size = c.get_child_count();
	grid_size.x = x_size;
	print("Grid-size: ", grid_size)
	
	for c in children:
		for cell in c.get_children():
			if cell.name.begins_with("spawn"):
				var e = test_entity.instance();
				e.global_transform = cell.global_transform;
				entities.add_child(e);
				#print(cell.name);
			else:
				#print("? ", cell.name);
				pass

func _prefill():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
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
	for y in range(grid_size.y):
		var t = "";
		for x in range(grid_size.x):
			if current_field[Vector2(x,y)].size() > 0:
				t += "_" + str(current_field[Vector2(x,y)].size()) + "a";
			else:
				t += " · ";
		print("= " + t + " =")
	print("=  =  =  =  =  =  =  =  =  =")
