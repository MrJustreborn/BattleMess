extends CanvasLayer

const MAX_TIME = 55;

onready var ctrl = $"/root/controller";

onready var progress = $Control2/TextureProgress;
onready var timer = $Control2/TextureProgress/Timer;
onready var text = $Control/Label;


func _ready():
	timer.start();
	#$Control.visible = false;
	pass

func _process(delta):
	progress.value = timer.time_left / MAX_TIME * 1000;
	var t = get_tree().get_nodes_in_group('active');
	if t.size() > 0:
		text.text = "Team: " + str(t[0].team);

func start():
	$Control.visible = true;
	timer.start();

func stop():
	$Control.visible = false;


func _on_Timer_timeout():
	pass # Replace with function body.
