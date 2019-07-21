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

var db = {}

func _ready():
	var d = Directory.new();
	d.open("res://plugins/entities/");
	d.list_dir_begin(true, true);
	var next = d.get_next();
	while next != "":
		if !d.current_is_dir() && next.ends_with(".json"):
			print("Load piece: ", "res://plugins/entities/" + next);
			var f = File.new();
			f.open("res://plugins/entities/" + next, File.READ);
			var result = JSON.parse(f.get_as_text()).result;
			f.close();
			_load(result);
		next = d.get_next();

func _load(what: Dictionary):
	var mesh
	var movementset = test_movementset.duplicate(true);
	mesh = load(what.mesh);
	
	for pos in what.movementset.first_move.discrete:
		movementset.first_move.discrete.append(Vector2(pos.x, pos.y));
	for pos in what.movementset.first_move.continuous:
		movementset.first_move.continuous.append(Vector2(pos.x, pos.y));
	
	for pos in what.movementset.move.discrete:
		movementset.move.discrete.append(Vector2(pos.x, pos.y));
	for pos in what.movementset.move.continuous:
		movementset.move.continuous.append(Vector2(pos.x, pos.y));
	
	for pos in what.movementset.merge.discrete:
		movementset.merge.discrete.append(Vector2(pos.x, pos.y));
	for pos in what.movementset.merge.continuous:
		movementset.merge.continuous.append(Vector2(pos.x, pos.y));
	
	for pos in what.movementset.kill.discrete:
		movementset.kill.discrete.append(Vector2(pos.x, pos.y));
	for pos in what.movementset.kill.continuous:
		movementset.kill.continuous.append(Vector2(pos.x, pos.y));
	
	movementset.kill.move_on_discete = what.movementset.kill.move_on_discete
	movementset.kill.move_on_continuous = what.movementset.kill.move_on_continuous
	
	db[what.id] = {}
	db[what.id]["name"] = what.name
	db[what.id]["level"] = what.level
	db[what.id]["mesh"] = mesh.duplicate();
	db[what.id]["movementset"] = movementset.duplicate(true);

func get_mesh(what: String):
	#print("load piece: ", what)
	return db[what]["mesh"].duplicate()# preload("res://test/entities/cone_mesh.tres");

func get_movementset(what: String):
	# print("load movement: ", what)
	return db[what]["movementset"].duplicate();
