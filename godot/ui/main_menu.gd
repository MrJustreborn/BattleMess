extends Control

onready var globals = $"/root/globals";
onready var ip_label = get_node("VBoxContainer/HBoxContainer2/ip");
onready var port = get_node("VBoxContainer/HBoxContainer2/port");
onready var player_name = get_node("VBoxContainer/HBoxContainer3/name");

func _ready():
	pass

func _set_address():
	globals.ip = ip_label.text;
	globals.port = int(port.text);
	globals.player_name = player_name.text;

func _on_Host_pressed():
	_set_address()
	if $"/root/network".host_server() == OK:
		get_tree().change_scene("res://test/testlvl.tscn"); #TODO: goto lobby
	else:
		printerr("Could not start server with: ", globals.ip, ":", globals.port);


func _on_Join_pressed():
	_set_address()
	if $"/root/network".join_server() == OK:
		get_tree().change_scene("res://test/testlvl.tscn"); #TODO: goto lobby
	else:
		printerr("Could not connect to server with: ", globals.ip, ":", globals.port);
