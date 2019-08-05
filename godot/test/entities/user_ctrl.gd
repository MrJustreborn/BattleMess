extends "res://test/entities/test_entity.gd"

func start():
	print("Got start call. ", is_in_group("active"));
	.start();
	_show_moves(true)
	for c in $move_preview.get_children():
		c.queue_free();
	$overlay/user_ctrl.visible = true;
	OS.set_window_title("BattleMess - Team: " + str(team) + " - Pos: " + str(pos) + " - Server: " + str(get_tree().is_network_server()));

#func update_pos(newpos):
#	.update_pos(newpos)
#	for c in $move_preview.get_children():
#		c.queue_free();

func _on_move_mouse_clicked(what, where):
	._on_move_mouse_clicked(what, where)
	for c in $move_preview.get_children():
		c.queue_free();
	
	if what == "move":
		grid_crtl.rpc("request_move", where)
		return;
	elif what == "merge":
		grid_crtl.rpc("request_merge", where)
		return;
	elif what == "kill":
		grid_crtl.rpc("request_kill", where)
		return;
	#var m = $Cone.duplicate();
	#$move_preview.add_child(m);
	#m.material_override = preload("res://test/entities/shadow_mat.tres");
	#m.global_transform = grid_crtl.cell_to_world(where);

#remotesync func _move_request_accepted(where):
#	var m = $piece.duplicate();
#	$move_preview.add_child(m);
#	m.material_override = preload("res://test/entities/shadow_mat.tres");
#	m.global_transform = grid_crtl.cell_to_world(where);
