extends Control

onready var chat = $"VBoxContainer/Panel/VBoxContainer/RichTextLabel";
onready var toSend = $"VBoxContainer/Panel/VBoxContainer/HBoxContainer/LineEdit"
onready var network = $"/root/network"

func _ready():
	pass


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

remotesync func _append_chat(player_name, text):
	chat.bbcode_text += "\n" + _get_timestamp() + "[color=red]" +player_name+ ":\n [color=white] " + text

master func _send_text(text):
	var from = get_tree().get_rpc_sender_id();
	if from == 0 && get_tree().is_network_server():
		from = 1;
	print("New chat message: ", text);
	var pName = network.players[from]
	rpc("_append_chat", pName, text);

func _on_Button_pressed():
	rpc("_send_text", toSend.text);
	toSend.text = "";