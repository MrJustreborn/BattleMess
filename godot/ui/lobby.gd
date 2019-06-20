extends Control

onready var chat = $"VBoxContainer/Panel/VBoxContainer/RichTextLabel";
onready var toSend = $"VBoxContainer/Panel/VBoxContainer/HBoxContainer/LineEdit"
onready var network = $"/root/network"

onready var team_1 = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/ItemList
onready var team_1_label = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/Label

onready var team_2 = $VBoxContainer/HBoxContainer/Panel2/VBoxContainer/ItemList
onready var team_2_label = $VBoxContainer/HBoxContainer/Panel2/VBoxContainer/Label

var teams = {
	1: {},
	2: {}
}

var max_players_per_team = 9; #testmap

func _ready():
	network.connect("updated_players", self, "_player_connected");
	_update_player_list();
	_update_labels();
	if get_tree().is_network_server():
		$VBoxContainer/HBoxContainer2.show();

func _player_connected(newList):
	rpc("_update_player_list")

remotesync func _update_player_list():
	team_1.clear();
	team_2.clear();
	var players = network.players;
	for p in players:
		if players[p]["team"] == "Team1":
			team_1.add_item(str(players[p]["player_name"]), load("res://icon.png"), false);
		elif players[p]["team"] == "Team2":
			team_2.add_item(str(players[p]["player_name"]), load("res://icon.png"), false);
	
	while team_1.get_item_count() < max_players_per_team:
		team_1.add_item("Free / Bot", null, false);
	while team_2.get_item_count() < max_players_per_team:
		team_2.add_item("Free / Bot", null, false);

func _get_timestamp():
	var time = OS.get_time()
	var h = time.hour
	var m = time.minute
	var s = time.second
	
	if h < 10:
		h = "0" + str(h);
	else:
		h = str(h)
	if m < 10:
		m = "0" + str(m);
	else:
		m = str(m)
	if s < 10:
		s = "0" + str(s);
	else:
		s = str(s)
	
	return "[color=gray] (" + h +":"+ m +":"+ s + ") "

remotesync func _append_chat(team, player_name, text):
	var color = "(?) [color=white]";
	if team == "Team1":
		color = "(1) [color=red]";
	elif team == "Team2":
		color = "(2) [color=green]";
	chat.bbcode_text += "\n" + _get_timestamp() + color +player_name+ ":\n [color=white] " + text

master func _send_text(text):
	var from = get_tree().get_rpc_sender_id();
	if from == 0 && get_tree().is_network_server():
		from = 1;
	print("New chat message: ", text);
	var pName = network.players[from]["player_name"]
	var team = network.players[from]["team"]
	rpc("_append_chat", team, pName, text);

func _on_Button_pressed():
	rpc("_send_text", toSend.text);
	toSend.text = "";

master func _request_join(which):
	var origin = get_tree().get_rpc_sender_id();
	if origin == 0 && get_tree().is_network_server():
		origin = 1;
	if teams[which].size() < max_players_per_team:
		teams[1].erase(origin)
		teams[2].erase(origin)
		teams[which][origin] = ""
		if origin == 1:
			_change_team(which);
		else:
			rpc_id(origin, "_change_team", which);
		
		_update_labels();

remote func _change_team(team):
	print(team)
	if team == 1:
		globals.team = "Team1";
	elif team == 2:
		globals.team = "Team2";
	else:
		globals.team = "";
	network.rpc("_set_player_data", globals.serialize());

func _update_labels():
	team_1_label.text = "Team 1 (" + str(teams[1].size()) + " / " + str(max_players_per_team) + ")"
	team_2_label.text = "Team 2 (" + str(teams[2].size()) + " / " + str(max_players_per_team) + ")"

func _on_Join1_pressed():
	rpc("_request_join", 1);

func _on_Join2_pressed():
	rpc("_request_join", 2);
