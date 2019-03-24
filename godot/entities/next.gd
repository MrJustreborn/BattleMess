extends Node2D

func _draw():
	if true:#OS.is_debug_build():
		draw_line(Vector2(), -position, Color("#a0a0a0"), 2, true);
