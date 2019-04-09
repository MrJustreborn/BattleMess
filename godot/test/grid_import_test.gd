extends Spatial

onready var grid = $grid;

func _ready():
	bubble_sort_children(grid)
	for i in range(grid.get_child_count()):
		print(grid.get_child(i).name, " -> ",grid.get_child(i).global_transform.origin);
	
	pass

func bubble_sort_children(node: Node, axis = "z"):
	var cnt = node.get_child_count();
	var n = cnt
	while n > 0:
		for i in range(cnt - 1):
			var a = node.get_child(i);
			var b = node.get_child(i + 1);
			if (a.global_transform.origin[axis] > b.global_transform.origin[axis]):
				print("swap ", a.name, " ",b.name)
				node.move_child(a, i + 1);
				node.move_child(b, i);
		n -= 1;
