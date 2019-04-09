extends Node

var consoleChar = "A" setget ,getchar

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

func _ready():
	pass

func getchar():
	return consoleChar;
