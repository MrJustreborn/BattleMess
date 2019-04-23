extends Node

func _ready():
	pass

func get_mesh(what: String):
	print("load piece: ", what)
	return preload("res://test/entities/cone_mesh.tres");

func get_movementset(what: String):
	print("load movement: ", what)
	return {
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
