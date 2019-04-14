extends Node

var fountain = preload("res://vfx/fountain.tscn");

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
					Vector2(2, 0), Vector2(2, 0)
					],
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

func _ready():
	$overlay.visible = false;
	pass

func init(ctrl, cell):
	grid_crtl = ctrl;
	pos = cell;

func _get_moves() -> Array:
	var can_move = [];
	for m in movementset.move.discrete:
		if grid_crtl.can_move(pos + m):
			can_move.append(pos + m);
	return can_move;

func _on_StaticBody_mouse_entered():
	#print(name)
	$Cone.scale = Vector3(1.2, 1.2, 1.2);
	var moves = _get_moves();
	for m in moves:
		var f = fountain.instance();
		$overlay/Spatial.add_child(f);
		f.global_transform = grid_crtl.cell_to_world(m);
		#$overlay/Spatial/fountain.global_transform = grid_crtl.cell_to_world(m);
	$overlay.visible = true;

func _on_StaticBody_mouse_exited():
	$Cone.scale = Vector3(1, 1, 1);
	for c in $overlay/Spatial.get_children():
		c.queue_free();
		pass
	$overlay.visible = false;
