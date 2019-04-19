extends Spatial

var type = "move" setget _set_move

func _ready():
	pass

func _set_move(what):
	type = what;
	match type:
		"move":
			$MeshInstance.material_override = preload("res://vfx/move_preview.tres");
		"merge":
			$MeshInstance.material_override = preload("res://vfx/merge_preview.tres");
		"kill":
			$MeshInstance.material_override = preload("res://vfx/kill_preview.tres");
