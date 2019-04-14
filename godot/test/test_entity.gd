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
		discrete = [],
		continuous = [],
		move_on_discete = true,
		move_on_continuous = true
	}
};

var grid_crtl = null
var pos = Vector2();
var team = null;

func _ready():
	$overlay.visible = false;
	print(team)
	pass

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

func _on_StaticBody_mouse_entered():
	#print(name)
	$Cone.scale = Vector3(1.2, 1.2, 1.2);
	var moves = _get_moves();
	var merges = _get_merges();
	
	for m in moves:
		var f = preview.instance();
		$overlay/Spatial.add_child(f);
		f.global_transform = grid_crtl.cell_to_world(m);
	for m in merges:
		var f = preview.instance();
		$overlay/Spatial.add_child(f);
		f.get_node("MeshInstance").material_override = preload("res://vfx/merge_preview.tres");
		f.global_transform = grid_crtl.cell_to_world(m);
	
	$overlay.visible = true;

func _on_StaticBody_mouse_exited():
	$Cone.scale = Vector3(1, 1, 1);
	for c in $overlay/Spatial.get_children():
		c.queue_free();
		pass
	$overlay.visible = false;
