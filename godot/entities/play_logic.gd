tool
extends "res://entities/entity.gd";

var col_move = Color("#a0a0a0")
var col_kill = Color("#f0000f")
var col_merge = Color("#000fff")
func _ready():
	setAi(ai)
	$Tween.connect("tween_completed", self, "tween_end");

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
	elif move.type == 3: #WALL
		$next.visible = false;
	
	$next.update();
	next_move = move;
	if move.type != 3: #WALL
		controller.add_predict_move(move.pos, self);

func cancel_next_move():
	next_move = null;
	merge_with = null;
	$next.position = Vector2();
	$next.visible = false;

func perform_next_move():
	$next.visible = false;
	controller.remove_node(cell);
	
	if next_move != null:
		if next_move.type == 0: #FREE
			setCell(next_move.pos);
			cancel_next_move();
		elif next_move.type == 1: #FRIEND
			#erge_with.setNextChessType();
			updateChess = true;
			#queue_free();
			#merge_with.setCell(next_move.pos);
			var new = Vector2(32 + 64 * next_move.pos.x, 32 + 64 * next_move.pos.y);
			$Tween.interpolate_property(self, "position", position, new, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			$Tween.start();
		elif next_move.type == 2: #OPPONENT
			toKill = controller.get_cell_item(next_move.pos);
			controller.remove_node(toKill.cell);
			#toKill.delete();
			setCell(next_move.pos);
	if !is_queued_for_deletion():
		controller.add_node(cell, self);
	#cancel_next_move();

#func delete():
#	controller.remove_node(cell);
#	queue_free();

var updateChess = false;
var toKill = null;
func tween_end(obj, path):
	if updateChess:
		controller.remove_node(cell);
		merge_with.setNextChessType();
		queue_free();
	elif toKill != null:
		toKill.queue_free();
	toKill = null;
	updateChess = false;
	cancel_next_move();

func setNextChessType():
	match type:
		chess_type.pawn:
			setChessType(chess_type.bishop);
		chess_type.bishop:
			setChessType(chess_type.knight);
		chess_type.knight:
			setChessType(chess_type.rock);
		chess_type.rock:
			setChessType(chess_type.king);
		chess_type.king:
			setChessType(chess_type.queen);
		chess_type.queen:
			return;

func want_to_merge_with(with: Node) -> bool:
	if merge_with != null || type == chess_type.queen:
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

