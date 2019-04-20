extends Node

var lock: Mutex = Mutex.new();

var current_field = {}
var future_field = {}
var field_type = {}
var pos_ref = {}
var entities = {}

var grid_size = Vector2(8, 8)

var user_ctrl = preload("res://test/entities/user_ctrl.gd")

var test_entity = preload("res://test/entities/testentity.tscn");

var grid: Node = null;


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	current_field = {}
	future_field = {}
	field_type = {}
	pos_ref = {}
	grid_size = Vector2(8, 8)
	grid = null;

func cell_to_world(cell: Vector2):
	#print(cell, " -> ", pos_ref[cell].global_transform);
	return pos_ref[cell].global_transform

func can_move(cell: Vector2) -> bool:
	#print(cell, " -> ", field_type[cell], " -> ", current_field[cell]);
	return _can_move_current(cell) && _can_move_future(cell);
func can_merge(who: Node, cell: Vector2) -> bool:
	return _can_merge_current(who, cell) && _can_merge_future(who, cell);
func can_kill(who: Node, cell: Vector2) -> bool:
	return _can_kill_current(who, cell) && _can_kill_future(who, cell);

func _can_move_current(cell: Vector2) -> bool:
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	return current_field[cell].empty() && (field_type[cell] == "move" || field_type[cell] == "move"); #spawn ? 
func _can_merge_current(who: Node, cell: Vector2) -> bool:
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	return !current_field[cell].empty() && current_field[cell][0].team == who.team;
func _can_kill_current(who: Node, cell: Vector2) -> bool:
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	return !current_field[cell].empty() && current_field[cell][0].team != who.team;
func _can_move_future(cell: Vector2) -> bool:
	lock.lock();
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	var can = future_field[cell].empty() && (field_type[cell] == "move" || field_type[cell] == "move"); #spawn ? 
	lock.unlock();
	return can;
func _can_merge_future(who: Node, cell: Vector2) -> bool:
	lock.lock();
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	var can = !future_field[cell].empty() && future_field[cell][0].team == who.team && future_field[cell][0] == current_field[cell][0];
	lock.unlock();
	return can;
func _can_kill_future(who: Node, cell: Vector2) -> bool:
	lock.lock();
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	var can = !future_field[cell].empty() && future_field[cell][0].team != who.team && future_field[cell][0] == current_field[cell][0];
	lock.unlock();
	return can;

func is_cell_free(cell: Vector2) -> bool:
	assert(grid);
	
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x || cell.y > grid_size.y:
		return false;
	
	print(grid.get_child(cell.y).get_child(cell.x).name);
	print(pos_ref[cell].name)
	
	return false;

func get_cell_entity(cell: Vector2) -> Node:
	return null;

func request_move(who: Node, cell: Vector2) -> bool:
	lock.lock();
	print("request_move: ", cell, " ", who, " can_move:", can_move(cell));#, " merge:", can_merge(who, cell), " kill:", can_kill(who, cell));
	var can = can_move(cell);
	if can:
		var curWhere = _get_future_cell_of(who);
		future_field[curWhere] = [];
		future_field[cell].append(who);
	else:
		can = cell == _get_future_cell_of(who);
	lock.unlock();
	_pretty_print("Future", future_field);
	return can;

func _get_future_cell_of(who: Node):
	for n in future_field:
		if !future_field[n].empty() && future_field[n][0] == who:
			return n;

func _input(event):
	if get_tree().is_network_server() && Input.is_action_just_pressed("ui_cancel"):
		print("end turn");
		_end_turn();

func _end_turn():
	for c in future_field:
		current_field[c] = future_field[c].duplicate();
	for c in current_field:
		if !current_field[c].empty():
			for n in current_field[c]:
				n.update_pos(c);
	_pretty_print();

func _player_connected(id):
	if get_tree().is_network_server():
		print("new player: ", id);
		for e in entities:
			if entities[e].empty():
				var cell = e.pos
				entities[e].append(id)
				rpc_id(id, "_set_player", cell);
				return;

remote func _set_player(cell):
	var e = current_field[cell][0];
	var t = e.team;
	e.set_script(user_ctrl)
	e.init(self, cell, t);

func init_grid(grid: Node, entities: Node):
	_ready(); #reset
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
			future_field[Vector2(x,y)] = [];
			field_type[Vector2(x,y)] = "void";
	
	var x = 0;
	var y = 0;
	for c in children:
		for cell in c.get_children():
			pos_ref[Vector2(x,y)] = cell;
			if cell.name.begins_with("spawn"):
				var e = test_entity.instance();
				entities.add_child(e);
				self.entities[e] = [];
				if Vector2(x,y) == Vector2(10,15) && get_tree().is_network_server():
					e.set_script(user_ctrl)
					self.entities[e].append(get_tree().get_network_unique_id());
					print("HERE");
				e.init(self, Vector2(x,y), cell.name.left(8));
				current_field[Vector2(x,y)].append(e);
				future_field[Vector2(x,y)].append(e);
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
	
	for c in current_field:
		if !current_field[c].empty():
			current_field[c][0].start();
	_pretty_print();

func _pretty_print(what = "Current", field = current_field):
	#print("[TYPE][NUMBER_PLAYER][AI/REAL = a/r]")
	print("\n", what, " field: ")
	var header = "=";
	for x in range(grid_size.x + 1):
		header = header + "  =";
	
	print(header)
	for y in range(grid_size.y):
		var t = "";
		for x in range(grid_size.x):
			if field[Vector2(x,y)].size() > 0:
				t += " " + str(field[Vector2(x,y)].size()) + " ";
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
