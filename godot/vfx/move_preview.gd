extends Spatial

var type = "move" setget _set_move
signal clicked(type)

func _ready():
	$StaticBody.connect("input_event", self, "input");
	$StaticBody.connect("mouse_entered", self, "_show_action");
	$StaticBody.connect("mouse_exited", self, "_hide_action");
	pass

func input(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed == false:
			print("clicked: ", type);
			emit_signal("clicked", type);

func _show_action():
	$MeshInstance2.visible = true;
func _hide_action():
	$MeshInstance2.visible = false;

func _set_move(what):
	type = what;
	match type:
		"move":
			$MeshInstance.material_override = preload("res://vfx/move_preview.tres");
			$MeshInstance2.material_override = preload("res://vfx/move_preview.tres");
		"merge":
			$MeshInstance.material_override = preload("res://vfx/merge_preview.tres");
			$MeshInstance2.material_override = preload("res://vfx/merge_preview.tres");
		"kill":
			$MeshInstance.material_override = preload("res://vfx/kill_preview.tres");
			$MeshInstance2.material_override = preload("res://vfx/kill_preview.tres");
