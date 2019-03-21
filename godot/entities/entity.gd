tool

extends Node2D

export(bool) var white = true setget setWhite;

func _ready():
	pass

func setWhite(value: bool):
	if value:
		$white.visible = true;
		$black.visible = false;
	else:
		$white.visible = false;
		$black.visible = true;
	white = value;
