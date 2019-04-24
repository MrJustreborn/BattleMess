extends Node

var test_mesh: Mesh = null;
var test_movementset: Dictionary = {
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

func _ready():
	var f = File.new();
	f.open("res://plugins/entities/pawn.json", File.READ);
	var result = JSON.parse(f.get_as_text()).result;
	f.close();
	_load(result);

func _load(what: Dictionary):
	test_mesh = load(what.mesh);
	
	for pos in what.movementset.move.discrete:
		test_movementset.move.discrete.append(Vector2(pos.x, pos.y));
	
	for pos in what.movementset.merge.discrete:
		test_movementset.merge.discrete.append(Vector2(pos.x, pos.y));
	
	for pos in what.movementset.kill.discrete:
		test_movementset.kill.discrete.append(Vector2(pos.x, pos.y));

func get_mesh(what: String):
	print("load piece: ", what)
	return preload("res://test/entities/cone_mesh.tres");

func get_movementset(what: String):
	print("load movement: ", what)
	return test_movementset.duplicate();
