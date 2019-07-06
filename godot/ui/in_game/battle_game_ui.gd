extends CanvasLayer

const MAX_TIME = 55;

onready var ctrl = $"/root/controller";

onready var progress = $Control/VBoxContainer/HBoxContainer/TextureProgress;
onready var timer = $Control/VBoxContainer/HBoxContainer/TextureProgress/Timer;


func _ready():
	timer.start();
	#$Control.visible = false;
	pass

func _process(delta):
	progress.value = timer.time_left / MAX_TIME * 1000;

func start():
	$Control.visible = true;
	timer.start();

func stop():
	$Control.visible = false;


func _on_Timer_timeout():
	pass # Replace with function body.
