extends Node

var ip: String;
var port: int;
var player_name: String;
var team: String;

func _ready():
	pass

func serialize():
	return {
		"player_name": player_name,
		"team": team
	}
