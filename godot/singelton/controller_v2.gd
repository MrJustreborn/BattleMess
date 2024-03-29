extends Node

var lock: Mutex = Mutex.new();

var current_field = {}
var future_field = {}
var field_type = {}
var pos_ref = {}
var entities = {}
var teams = {}

var grid_size = Vector2(8, 8)

var user_ctrl = preload("res://test/entities/user_ctrl.gd")

var test_entity = preload("res://test/entities/testentity.tscn");

var grid: Node = null;

var readyClients = [];

var is_init: bool = false;
func _ready():
	is_init = false;
	#get_tree().connect("network_peer_connected", self, "_player_connected")
	current_field = {}
	future_field = {}
	field_type = {}
	pos_ref = {}
	grid_size = Vector2(8, 8)
	grid = null;
	readyClients = [];

func cell_to_world(cell: Vector2):
	#print(cell, " -> ", pos_ref[cell].global_transform);
	return pos_ref[cell].global_transform

#master func test_FUNC():
#	var from = get_tree().get_rpc_sender_id();
#	print("CALLED TEST_FUNC: ", from, " ",get_tree().get_network_unique_id())
#	if from == 0 and get_tree().is_network_server():
#		for e in entities:
#			if entities[e].has(from):
#				print("call local")
#				e.set_moves(["test from master"]);
#	else:
#		for e in entities:
#			if entities[e].has(from):
#				print("WRONG CALL, MUST BE MASTER!!")
#				#e.rpc_id(from, "set_moves", "test from master");

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
	return current_field[cell].empty() && (field_type[cell] == "move" || field_type[cell] == "move" || field_type[cell] == "spawn"); #spawn ? 
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
	var can = future_field[cell].empty() && (field_type[cell] == "move" || field_type[cell] == "move" || field_type[cell] == "spawn"); #spawn ? 
	lock.unlock();
	return can;
func _can_merge_future(who: Node, cell: Vector2) -> bool:
	lock.lock();
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	var can = !future_field[cell].empty() && future_field[cell][0].team == who.team && future_field[cell][0] == current_field[cell][0] && future_field[cell].size() < 2;
	lock.unlock();
	return can;
func _can_kill_future(who: Node, cell: Vector2) -> bool:
	lock.lock();
	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x - 1 || cell.y > grid_size.y - 1:
		return false;
	var can = !future_field[cell].empty() && future_field[cell][0].team != who.team && future_field[cell][0] == current_field[cell][0] && future_field[cell].size() < 2;
	lock.unlock();
	return can;

#func is_cell_free(cell: Vector2) -> bool:
#	assert(grid);
#	
#	if cell.x < 0 || cell.y < 0 || cell.x > grid_size.x || cell.y > grid_size.y:
#		return false;
#	
#	print(grid.get_child(cell.y).get_child(cell.x).name);
#	print(pos_ref[cell].name)
#	
#	return false;

func get_ref(id):
	print("Get ref for: ", id)
	for n in entities:
		print("search: ", entities[n], " -> ",entities[n].has(id));
		if !entities[n].empty() && entities[n].has(id):
			print(n, " -> ", n.name);
			return n;

# # # # #
# Moves
# # # # #
master func request_move(cell: Vector2) -> bool:
	var from = get_tree().get_rpc_sender_id();
	if from == 0 && get_tree().is_network_server():
		from = 1;
	var who = get_ref(from);
	lock.lock();
	print("request_move: ", cell, " ", who, " can_move:", can_move(cell));#, " merge:", can_merge(who, cell), " kill:", can_kill(who, cell));
	var can = can_move(cell);
	if can:
		var curWhere = _get_future_cell_of(who);
		var where = future_field[curWhere].find(who);
		if where > -1:
			future_field[curWhere].remove(where);
		future_field[cell].append(who);
	else:
		can = cell == _get_future_cell_of(who);
	lock.unlock();
	_pretty_print("Future", future_field);
	if can:
		print("send rpc to: ", from)
		#if from == 0 || from == 1:
		#	who._move_request_accepted(cell);
		#else:
		#	who.rpc_id(from, "_move_request_accepted", cell);
		who.rpc("_move_request_accepted", cell);
	return can;

# # # # #
# Kills
# # # # #
master func request_kill(cell: Vector2) -> bool:
	var from = get_tree().get_rpc_sender_id();
	if from == 0 && get_tree().is_network_server():
		from = 1;
	var who = get_ref(from);
	lock.lock();
	print("request_kill: ", cell, " ", who, " can_kill:", can_kill(who, cell));#, " merge:", can_merge(who, cell), " kill:", can_kill(who, cell));
	var can = can_kill(who, cell);
	if can:
		var curWhere = _get_future_cell_of(who);
		var where = future_field[curWhere].find(who);
		if where > -1:
			future_field[curWhere].remove(where);
		for i in future_field[curWhere]:
			print("Kill: ", i);
		future_field[cell].append(who);
	else:
		can = cell == _get_future_cell_of(who);
	lock.unlock();
	_pretty_print("Future", future_field);
	if can:
		print("send rpc to: ", from)
		who.rpc("_kill_request_accepted", cell);
	return can;

# # # # #
# Merges
# # # # #
master func request_merge(cell: Vector2) -> bool:
	var from = get_tree().get_rpc_sender_id();
	if from == 0 && get_tree().is_network_server():
		from = 1;
	var who = get_ref(from);
	lock.lock();
	print("request_merge: ", cell, " ", who, " can_kill:", can_merge(who, cell));#, " merge:", can_merge(who, cell), " kill:", can_kill(who, cell));
	var can = can_merge(who, cell);
	if can:
		var curWhere = _get_future_cell_of(who);
		var where = future_field[curWhere].find(who);
		if where > -1:
			future_field[curWhere].remove(where);
		for i in future_field[curWhere]:
			print("Merge: ", i);
		future_field[cell].append(who);
	else:
		can = cell == _get_future_cell_of(who);
	lock.unlock();
	_pretty_print("Future", future_field);
	if can:
		print("send rpc to: ", from)
		who.rpc("_merge_request_accepted", cell);
	return can;

master func _client_ready():
	var origin = get_tree().get_rpc_sender_id();
	print(origin, " is ready. ", network.players[origin]);
	readyClients.append(origin)
	var playerSize = network.players.size();
	print(readyClients.size(), " of ", playerSize);
	if readyClients.size() == playerSize - 1:
		print("all ready!");
		get_tree().change_scene("res://test/testlvl.tscn");

func _get_future_cell_of(who: Node):
	for n in future_field:
		if !future_field[n].empty() && future_field[n].find(who) > -1: #TODO: check all positions
			return n;

func _input(event):
	if is_init && get_tree().is_network_server() && Input.is_action_just_pressed("ui_cancel"):
		_change_teams();
		for t in teams:
			get_tree().call_group(t, 'set_active', teams[t]) #TODO: should rpc
		for i in range(250):
			yield(get_tree(), "idle_frame"); # wait to set group
		print("end turn");
		#yield(self, "all_changed");
		_end_turn();
		print(teams)

func _change_teams():
	var firstStart = false;
	for t in teams:
		if teams[t] == false:
			firstStart = true;
		else:
			firstStart = false;
			break;
	if firstStart:
		teams['spawn[0]'] = true;
		return;
	#TODO: support more then two teams
	if teams['spawn[0]']:
		teams['spawn[0]'] = false;
		teams['spawn[1]'] = true;
	else:
		teams['spawn[0]'] = true;
		teams['spawn[1]'] = false;

func update_merged(ref, merged_players):
	#var from = get_tree().get_rpc_sender_id();
	#if from == 0 && get_tree().is_network_server():
	#	from = 1;
	#var ref = get_ref(from)
	print(ref, ref.merged_players, merged_players, ref.pos)
	for m in merged_players:
		if int(m) == 1 && get_tree().is_network_server():
			set_player_TMP(ref.pos, merged_players, current_field[ref.pos][0].get_path())
		else:
			rpc_id(int(m), "set_player_TMP", ref.pos, merged_players, current_field[ref.pos][0].get_path());

remote func set_player_TMP(cell, merged_players, path: NodePath):
	print("Merge: ", path)
	var e = get_node(path);#current_field[cell][0]; #TODO: slave don't have this arr
	var t = e.team;
	print(e)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	print("set_script")
	e.set_script(user_ctrl)
	yield(get_tree(), "idle_frame")
	e.init_new_player(self, cell, t, merged_players, "pawn_v2"); #TODO: set mesh!!!

# TODO: fix this mess
var remoteActive = {};
signal all_changed;
master func player_state_changed(active: int):
	var origin = get_tree().get_rpc_sender_id();
	
	print("Remote active changed: ", origin, " -> ", active);
	var localActive = get_tree().get_nodes_in_group('active');
	remoteActive[origin] = active;
	
	for a in remoteActive:
		var ok = false;
		if remoteActive[a] == localActive.size():
			ok = true;
		else:
			break;
		if ok:
			print("All remote active changed");
			emit_signal("all_changed");
			remoteActive = {};

func _end_turn():
	for c in future_field:
		current_field[c] = future_field[c].duplicate();
	for c in current_field:
		if !current_field[c].empty():
			if current_field[c].size() > 1:
				if current_field[c][0].team != current_field[c][1].team:
					current_field[c][1].kill_node = current_field[c][0];
				else:
					current_field[c][1].merge_with = current_field[c][0];
					entities[current_field[c][1]].append(int(current_field[c][0].name))
				current_field[c].remove(0);
				future_field[c].remove(0);
			for n in current_field[c]:
				n.rpc("update_pos", c);
	_pretty_print();
	print("Recheck entities ref: ", entities.size())
	var toRemove = []
	for e in entities:
		if !is_instance_valid(e):
			toRemove.append(e)
	for t in toRemove:
		entities.erase(t)
	print("Updated entities ref: ", entities.size())

func _player_connected(id):
	if get_tree().is_network_server():
		print("new player: ", id);
		for e in entities:
			if entities[e].empty():
				e.name = str(id);
				var cell = e.pos
				entities[e].append(id)
				rpc_id(id, "_set_player", cell);
				break;
		for e in entities:
				rpc("_update_player_node_name", e.pos, e.name);

func _set_players():
	var players = network.players;
	for p in players:
		var team = players[p].team;
		if team == "Team1":
			team = "spawn[0]";
		else:
			team = "spawn[1]";
		for e in entities:
			if entities[e].empty() && e.team == team:
				print(p, " ", e, " ", team, e.team, e.pos)
				e.name = str(p);
				var cell = e.pos
				entities[e].append(p)
				rpc_id(p, "_set_player", cell);
				if p == 1 && get_tree().is_network_server():
					var t = e.team;
					e.set_script(user_ctrl);
					e.name = str(1);
					e.init(self, cell, t);
				break;
		for e in entities:
				rpc("_update_player_node_name", e.pos, e.name);

puppet func _update_player_node_name(cell, new_name): #todo: is this reliable?
	print("update: ", cell, " -> ", new_name);
	current_field[cell][0].name = new_name;

remote func _set_player(cell):
	var e = current_field[cell][0];
	var t = e.team;
	e.set_script(user_ctrl)
	e.name = str(get_tree().get_network_unique_id());
	e.init(self, cell, t);

func init_grid(grid: Node, entities: Node):
	_ready(); #reset
	is_init = true;
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
				e.name = "Bot " + str(x) + str(y);
				entities.add_child(e);
				self.entities[e] = [];
				#if Vector2(x,y) == Vector2(10,15) && get_tree().is_network_server():
				#	e.set_script(user_ctrl)
				#	e.name = "1"
				#	self.entities[e].append(0);
				#	self.entities[e].append(get_tree().get_network_unique_id());
				#	print("HERE");
				teams[cell.name.left(8)] = false;
				e.init(self, Vector2(x,y), cell.name.left(8)); # TODO: define teams correctly
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
	if !get_tree().is_network_server():
		rpc("_client_ready");
	else:
		print("set players")
		_set_players();

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
				t += " " + str(field[Vector2(x,y)].size()) + _get_field_type_char_kill_merge(field, Vector2(x,y));
			else:
				t += " " +_get_field_type_char(field_type[Vector2(x,y)])+ " ";
		print("= " + t + " =")
	print(header)

func _get_field_type_char_kill_merge(field, pos: Vector2):
	if field[pos].size() > 1:
		if field[pos][0].team != field[pos][1].team:
			return "k";
		else:
			return "m";
	else:
		return " ";

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
