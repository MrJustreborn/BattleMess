extends Spatial

export(NodePath) var grid_node;

var grid: Node = null;

onready var grid_ctrl = get_node("/root/controller")#preload("res://singelton/controller_v2.gd").new()

func _ready():
	grid = get_node(grid_node);
	assert(grid);
	bubble_sort_children(grid);
	for i in range(grid.get_child_count()):
		bubble_sort_children(grid.get_child(i), "x");
		#print(grid.get_child(i).name, " -> ",grid.get_child(i).global_transform.origin);
	grid_ctrl.init_grid(grid, $entities);
	print(grid_ctrl, grid_ctrl.is_inside_tree())

func bubble_sort_children(node: Node, axis = "z"):
	var cnt = node.get_child_count();
	var n = cnt
	while n > 0:
		for i in range(n - 1):
			var a = node.get_child(i);
			var b = node.get_child(i + 1);
			if (a.global_transform.origin[axis] > b.global_transform.origin[axis]):
				#print("swap ", a.name, " ",b.name)
				node.move_child(a, i + 1);
				node.move_child(b, i);
		n -= 1;
