extends "res://test/entities/test_entity.gd"

func start():
	.start();
	_show_moves(true)
	for c in $move_preview.get_children():
		c.queue_free();
	$overlay/user_ctrl.visible = true;

func update_pos(newpos):
	.update_pos(newpos)
	for c in $move_preview.get_children():
		c.queue_free();

func _on_move_mouse_clicked(what, where):
	._on_move_mouse_clicked(what, where)
	for c in $move_preview.get_children():
		c.queue_free();
	
	if what == "move":
		grid_crtl.rpc("request_move", where)
		return;
	#var m = $Cone.duplicate();
	#$move_preview.add_child(m);
	#m.material_override = preload("res://test/entities/shadow_mat.tres");
	#m.global_transform = grid_crtl.cell_to_world(where);

remote func _move_request_accepted(where):
	var m = $Cone.duplicate();
	$move_preview.add_child(m);
	m.material_override = preload("res://test/entities/shadow_mat.tres");
	m.global_transform = grid_crtl.cell_to_world(where);
