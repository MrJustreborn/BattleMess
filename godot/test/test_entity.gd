extends Node

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

func _ready():
	$overlay.visible = false;
	pass

func init(ctrl, cell):
	grid_crtl = ctrl;
	pos = cell;
	print(pos);

func _on_StaticBody_mouse_entered():
	$Cone.scale = Vector3(1.2, 1.2, 1.2);
	$overlay/Spatial.global_transform = grid_crtl.cell_to_world(pos - Vector2(0, 2));
	$overlay.visible = true;


func _on_StaticBody_mouse_exited():
	$Cone.scale = Vector3(1, 1, 1);
	$overlay.visible = false;
