extends Spatial

var preview = preload("res://vfx/move_preview.tscn");

# relative movements to current position
var movementset = {
	first_move = {
		discrete = [],
		continuous = []
	},
	move = {
		discrete = [
					Vector2(0, -1), Vector2(0, -2),
					Vector2(0, 1), Vector2(0, 2),
					Vector2(-1, 0), Vector2(-2, 0),
					Vector2(1, 0), Vector2(2, 0)
					],
		continuous = []
	},
	merge = {
		discrete = [
					Vector2(1, 1),
					Vector2(1, -1),
					Vector2(-1, 1),
					Vector2(-1, -1),
					],
		continuous = []
	},
	kill = {
		discrete = [
					Vector2(-9, -15)
					],
		continuous = [],
		move_on_discete = true,
		move_on_continuous = true
	}
};

var grid_crtl = null
var pos = Vector2();
var team = null;

func _ready():
	#print("Ready: ",team);
	#print("Network: ", get_tree().is_network_server());
	pass

func init(ctrl, cell, team):
	grid_crtl = ctrl;
	pos = cell;
	self.team = team;
	if is_inside_tree():
		#print("REINIT_ENTITY!");
		start();

func start():
	global_transform = grid_crtl.cell_to_world(pos);
	_show_moves(false);

func update_pos(newpos): #todo: use setget
	_show_moves(false);
	if newpos != pos:
		pos = newpos;
		$Tween.interpolate_property(self, "global_transform",
		global_transform, grid_crtl.cell_to_world(newpos), 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.connect("tween_completed", self, "_pos_updated", [], CONNECT_ONESHOT);
		$Tween.start()

func _pos_updated(obj, key):
	start();

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
	if from == 0 and get_tree().is_network_server():
		_set_moves_remote(can_move);
	else:
		rpc_id(from, "_set_moves_remote", can_move);

func _get_moves() -> Array:
	var can_move = [];
	for m in movementset.move.discrete:
		if grid_crtl.can_move(pos + m):
			can_move.append(pos + m);
	return can_move;
func _get_merges() -> Array:
	var can_merge = [];
	for m in movementset.merge.discrete:
		if grid_crtl.can_merge(self, pos + m):
			can_merge.append(pos + m);
	return can_merge;
func _get_kills() -> Array:
	var can_kill = [];
	for m in movementset.kill.discrete:
		if grid_crtl.can_kill(self, pos + m):
			can_kill.append(pos + m);
	return can_kill;

func _show_moves(visible = true):
	if visible:
		#$Cone.scale = Vector3(1.2, 1.2, 1.2);
		print("pre: ", cur_moves)
		rpc("_get_moves_remote");
		yield(self,"got_moves")
		print("post: ", cur_moves)
		#print(name)
		var moves = _get_moves();
		var merges = _get_merges();
		var kills = _get_kills();
		
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

func _on_move_mouse_clicked(what, where):
	print(what, " ", where)

func _on_StaticBody_mouse_entered():
	_show_moves(true);

func _on_StaticBody_mouse_exited():
	_show_moves(false);
