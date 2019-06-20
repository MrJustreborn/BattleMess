extends Control

onready var globals = $"/root/globals";
onready var ip_label = get_node("VBoxContainer/HBoxContainer2/ip");
onready var port = get_node("VBoxContainer/HBoxContainer2/port");
onready var player_name = get_node("VBoxContainer/HBoxContainer3/name");
onready var level_select_popup = $WindowDialog

func _ready():
	pass

func _set_address():
	globals.ip = ip_label.text;
	globals.port = int(port.text);
	globals.player_name = player_name.text;

func _on_Host_pressed():
	_set_address()
	level_select_popup.popup_centered()
	yield(level_select_popup, "hide");
	if $"/root/network".host_server() == OK:
		get_tree().change_scene("res://ui/lobby.tscn"); #TODO: goto lobby
	else:
		printerr("Could not start server with: ", globals.ip, ":", globals.port);


func _on_Join_pressed():
	_set_address()
	if $"/root/network".join_server() == OK:
		get_tree().change_scene("res://ui/lobby.tscn"); #TODO: goto lobby
	else:
		printerr("Could not connect to server with: ", globals.ip, ":", globals.port);
