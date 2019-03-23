tool
extends "res://entities/entity.gd";

export(bool) var ai = true setget setAi;

var col_move = Color("#a0a0a0")
var col_kill = Color("#f0000f")
var col_merge = Color("#000fff")
func _ready():
	setAi(ai)

var merge_with = null;
var next_move = null;
func predict_next_move():
	if !ai || merge_with != null:
		return
	
	if randf() < .2:
		return
	
	var next = get_posible_moves();
	if next.size() == 0:
		return;
	var move = next[randi() % next.size()]
	
	var ok = false;
	var max_tries = 5;
	var try = 0;
	while(!ok):
		try += 1
		if move.type == 1:
			var item = controller.get_cell_item(move.pos);
			var want = item.want_to_merge_with(self)
			if want:
				ok = true;
				merge_with = item;
			else:
				move = next[randi() % next.size()]
		else:
			ok = true;
		if try > max_tries:
			return;
	
	var pos = move.pos
	var to = Vector2(pos.x - cell.x, pos.y - cell.y);
	$next.position = Vector2(to.x * 64, to.y * 64);
	$next.visible = true;
	
	if move.type == 0: #FREE
		$next/Circle/CPUParticles2D.color = col_move;
	elif move.type == 1: #FRIEND
		$next/Circle/CPUParticles2D.color = col_merge;
	elif move.type == 2: #OPPONENT
		$next/Circle/CPUParticles2D.color = col_kill;
	
	$next.update();
	next_move = move;
	controller.add_predict_move(move.pos, self);

func cancel_next_move():
	next_move = null;
	merge_with = null;
	$next.position = Vector2();
	$next.visible = false;

func perform_next_move():
	controller.remove_node(cell);
	
	if next_move != null:
		if next_move.type == 0: #FREE
			setCell(next_move.pos);
		elif next_move.type == 1: #FRIEND
			merge_with.delete();
			setChessType(chess_type.bishop);
			setCell(next_move.pos);
		elif next_move.type == 2: #OPPONENT
			pass
	
	controller.add_node(cell, self);
	cancel_next_move();

func delete():
	controller.remove_node(cell);
	queue_free();

func want_to_merge_with(with: Node) -> bool:
	if merge_with != null:
		return false;
	var want: bool = randf() > .5;
	if want:
		merge_with = with;
		if next_move:
			controller.remove_predict_move(next_move.pos)
		next_move = null;
		$next.position = Vector2();
		$next.visible = false;
	return want;

func setAi(what):
	ai = what
	if ai:
		$you.visible = false;
	else:
		$you.visible = true;
