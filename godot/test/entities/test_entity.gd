extends Spatial

var preview = preload("res://vfx/move_preview.tscn");

# relative movements to current position
var movementset = {
	first_move = {
		discrete = [],
		continuous = []
	},
	move = {
		discrete = [],
		continuous = []
	},
	merge = {
		discrete = [],
		continuous = []
	},
	kill = {
		discrete = [],
		continuous = [],
		move_on_discete = true,
		move_on_continuous = true
	}
};

var grid_crtl = null
var pos = Vector2();
var team = null;

var MAT1 = SpatialMaterial.new();
var MAT2 = SpatialMaterial.new();

var merge_with: Node = null;
var kill_node: Node = null;

func _ready():
	print("Ready: ",team);
	#print("Network: ", get_tree().is_network_server());
	#add_to_group(team)
	pass

func init(ctrl, cell, team, piece = "pawn"):
	grid_crtl = ctrl;
	pos = cell;
	self.team = team;
	add_to_group(team)
	if is_inside_tree():
		#print("REINIT_ENTITY!");
		start();
	setMesh(piece);

puppet func setMesh(piece):
	$piece.mesh = get_node("/root/piece_loader").get_mesh(piece);
	movementset = get_node("/root/piece_loader").get_movementset(piece);
	
	if self.team == "spawn[0]":
		$piece.mesh.surface_set_material(0, MAT1);
		MAT1.albedo_color = Color("#ffffff");
	else:
		$piece.mesh.surface_set_material(0, MAT2);
		MAT2.albedo_color = Color("#000000");

func start():
	global_transform = grid_crtl.cell_to_world(pos);
	_show_moves(false);

remotesync func update_pos(newpos): #todo: use setget
	for c in $move_preview.get_children():
		c.queue_free();
	_show_moves(false);
	if newpos != pos:
		pos = newpos;
		#$Tween.interpolate_property(self, "global_transform",
		#global_transform, grid_crtl.cell_to_world(newpos), 1,
		#Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#$Tween.connect("tween_completed", self, "_pos_updated", [], CONNECT_ONESHOT);
		#$Tween.start()
		var origin = global_transform.origin;
		var newOrigin = grid_crtl.cell_to_world(newpos).origin;
		var heighPoint = (origin + newOrigin) / 2;
		heighPoint.y += (newOrigin - origin).length();
		jumpCurve.clear_points();
		jumpCurve.add_point(origin);
		jumpCurve.add_point(heighPoint)#, Vector3(0, 0, 1), Vector3(0, 0, -1)); #todo calc controll points
		jumpCurve.add_point(newOrigin);
		$Tween.interpolate_method(self, "_jump", 0.0, jumpCurve.get_baked_length(), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.connect("tween_completed", self, "_pos_updated", [], CONNECT_ONESHOT);
		$Tween.start()
	else:
		_pos_updated(null, null);

func _pos_updated(obj, key):
	if kill_node:
		kill_node.rpc("remove_entity");
		kill_node = null;
	if merge_with:
		if get_tree().is_network_server():
			setMesh("pawn_v2");
			rpc("setMesh", "pawn_v2");
			merge_with.rpc("remove_entity", false);
		merge_with = null;
	start();

var jumpCurve = Curve3D.new()
func _jump(pos: float):
	global_transform.origin = jumpCurve.interpolate_baked(pos);

remotesync func remove_entity(kill = true):
	var from = get_tree().get_rpc_sender_id();
	if from == 0 || from == 1:
		queue_free();
		print("remove entity")

# # # # #
# Moves
# # # # #
var cur_moves;
signal got_moves
puppet func _set_moves_remote(moves: Array):
	cur_moves = moves;
	emit_signal("got_moves");

master func _get_moves_remote():
	var from = get_tree().get_rpc_sender_id();
	print("get moves remote: ", from)
	var can_move = [];
	for m in movementset.move.discrete:
		if grid_crtl.can_move(pos + m):
			can_move.append(pos + m);
	print("(",from,") got ", can_move.size(), " moves");
	if from == 0 and get_tree().is_network_server():
		_set_moves_remote(can_move);
	else:
		rpc_id(from, "_set_moves_remote", can_move);

# # # # #
# Merges
# # # # #
var cur_merges;
signal got_merges
puppet func _set_merges_remote(merges: Array):
	cur_merges = merges;
	emit_signal("got_merges");

master func _get_merges_remote():
	var from = get_tree().get_rpc_sender_id();
	print("get merges remote: ", from)
	var can_merge = [];
	for m in movementset.merge.discrete:
		if grid_crtl.can_merge(self, pos + m):
			can_merge.append(pos + m);
	print("(",from,") got ", can_merge.size(), " merges");
	if from == 0 and get_tree().is_network_server():
		_set_merges_remote(can_merge);
	else:
		rpc_id(from, "_set_merges_remote", can_merge);

# # # # #
# Kills
# # # # #
var cur_kills;
signal got_kills
puppet func _set_kills_remote(kills: Array):
	cur_kills = kills;
	emit_signal("got_kills");

master func _get_kills_remote():
	var from = get_tree().get_rpc_sender_id();
	print("get kills remote: ", from)
	var can_kill = [];
	for m in movementset.kill.discrete:
		if grid_crtl.can_kill(self, pos + m):
			can_kill.append(pos + m);
	print("(",from,") got ", can_kill.size(), " kills");
	if from == 0 and get_tree().is_network_server():
		_set_kills_remote(can_kill);
	else:
		rpc_id(from, "_set_kills_remote", can_kill);

func _get_moves() -> Array:
	rpc("_get_moves_remote");
	if get_tree().is_network_server():
		yield(get_tree(), "idle_frame");
	else:
		yield(self,"got_moves")
	return cur_moves;
func _get_merges() -> Array:
	rpc("_get_merges_remote");
	if get_tree().is_network_server():
		yield(get_tree(), "idle_frame");
	else:
		yield(self,"got_merges")
	return cur_merges;
func _get_kills() -> Array:
	rpc("_get_kills_remote");
	if get_tree().is_network_server():
		yield(get_tree(), "idle_frame");
	else:
		yield(self,"got_kills")
	return cur_kills;

func _show_moves(visible = true):
	if visible && is_in_group('active'):
		#$Cone.scale = Vector3(1.2, 1.2, 1.2);
		var moves = _get_moves();
		if typeof(moves) == TYPE_OBJECT and moves.is_class("GDScriptFunctionState"):
			moves = yield(moves, "completed")
		var merges = _get_merges();
		if typeof(merges) == TYPE_OBJECT and merges.is_class("GDScriptFunctionState"):
			merges = yield(merges, "completed")
		var kills = _get_kills();
		if typeof(kills) == TYPE_OBJECT and kills.is_class("GDScriptFunctionState"):
			kills = yield(kills, "completed")
		
		for m in moves:
			var f = preview.instance();
			f.type = "move";
			$overlay/moves.add_child(f);
			f.connect("clicked", self, "_on_move_mouse_clicked", [m]);
			f.global_transform = grid_crtl.cell_to_world(m);
		for m in merges:
			var f = preview.instance();
			f.type = "merge";
			$overlay/moves.add_child(f);
			f.connect("clicked", self, "_on_move_mouse_clicked", [m]);
			f.global_transform = grid_crtl.cell_to_world(m);
		for m in kills:
			var f = preview.instance();
			f.type = "kill";
			$overlay/moves.add_child(f);
			f.connect("clicked", self, "_on_move_mouse_clicked", [m]);
			f.global_transform = grid_crtl.cell_to_world(m);
		$overlay/moves.visible = true;
	else:
		#$Cone.scale = Vector3(1, 1, 1);
		for c in $overlay/moves.get_children():
			c.queue_free();
			pass
		$overlay/moves.visible = false;

puppet func set_active(isActive):
	var origin = get_tree().get_rpc_sender_id();
	if get_tree().is_network_server() || origin == 1:
		print(team, " Set active to: ", isActive)
		if isActive:
			add_to_group('active');
		elif is_in_group('active'):
			remove_from_group('active');
	if get_tree().is_network_server():
		rpc('set_active', isActive);
#	yield(get_tree(), "idle_frame");
#	var localActive = get_tree().get_nodes_in_group('active');
#	grid_crtl.rpc("player_state_changed", localActive.size());

func _on_move_mouse_clicked(what, where):
	print(what, " ", where)

remotesync func _move_request_accepted(where):
	_show_accepted_request(where)
remotesync func _kill_request_accepted(where):
	_show_accepted_request(where)
remotesync func _merge_request_accepted(where):
	_show_accepted_request(where)

func _show_accepted_request(where):
	for c in $move_preview.get_children():
		c.queue_free();
	var m = $piece.duplicate();
	$move_preview.add_child(m);
	m.material_override = preload("res://test/entities/shadow_mat.tres");
	m.global_transform = grid_crtl.cell_to_world(where);

