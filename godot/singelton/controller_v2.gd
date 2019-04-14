tool
extends Node

var lock: Mutex = Mutex.new();

var current_field = {}
var future_field = {}
var field_type = {}
var pos_ref = {}

var grid_size = Vector2(8, 8)

var entity = preload("res://test/test_entity.gd")

var test_entity = preload("res://test/testentity.tscn");

var grid: Node = null;


func _ready():
	pass;

func cell_to_world(cell: Vector2):
	#print(cell, " -> ", pos_ref[cell].global_transform);
	return pos_ref[cell].global_transform

func can_move(cell: Vector2) -> bool:
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	#print(cell, " -> ", field_type[cell], " -> ", current_field[cell]);
	return current_field[cell].empty() && field_type[cell] == "move";

func is_cell_free(cell: Vector2) -> bool:
	assert(grid);
	
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x || cell.y > grid_size.y:
		return false;
	
	print(grid.get_child(cell.y).get_child(cell.x).name);
	print(pos_ref[cell].name)
	
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
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			current_field[Vector2(x,y)] = [];
			field_type[Vector2(x,y)] = "void";
	
	var x = 0;
	var y = 0;
	for c in children:
		for cell in c.get_children():
			pos_ref[Vector2(x,y)] = cell;
			if cell.name.begins_with("spawn"):
				var e = test_entity.instance();
				e.global_transform = cell.global_transform;
				e.init(self, Vector2(x,y));
				entities.add_child(e);
				current_field[Vector2(x,y)].append(e);
				field_type[Vector2(x,y)] = "spawn";
			elif cell.name.begins_with("move"):
				field_type[Vector2(x,y)] = "move";
			elif cell.name.begins_with("wall"):
				field_type[Vector2(x,y)] = "wall";
			elif cell.name.begins_with("gap"):
				field_type[Vector2(x,y)] = "gap";
			else:
				#print("? ", cell.name);
				pass
			x = x + 1;
		x = 0;
		y = y + 1;
	_pretty_print();

func _pretty_print():
	#print("[TYPE][NUMBER_PLAYER][AI/REAL = a/r]")
	print("\nCurrent field: ")
	var header = "=";
	for x in range(grid_size.x + 1):
		header = header + "  =";
	
	print(header)
	for y in range(grid_size.y):
		var t = "";
		for x in range(grid_size.x):
			if current_field[Vector2(x,y)].size() > 0:
				t += " " + str(current_field[Vector2(x,y)].size()) + " ";
			else:
				t += " " +_get_field_type_char(field_type[Vector2(x,y)])+ " ";
		print("= " + t + " =")
	print(header)

func _get_field_type_char(type: String):
	match type:
		"void":
			return " ";
		"spawn":
			return "S";
		"move":
			return ".";
		"wall":
			return "X";
		"gap":
			return "/";
		_:
			return "?";
