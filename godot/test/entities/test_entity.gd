extends Node

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
	print(team);

func init(ctrl, cell, team):
	grid_crtl = ctrl;
	pos = cell;
	self.team = team;

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
