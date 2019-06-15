extends Node

onready var globals = $"/root/globals";

var players = {};

func _ready():
	print("\n===\n")
	var f = File.new()
	if f.file_exists("res://singelton/server.gd"):
		var test = load("res://singelton/server.gd")
		print(test)
		test = test.new();
		print(test)
	print("\n===\n")
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_to_server_ok")
#	if host_server() != OK:
#		join_server();

var time = 0;
func _process(delta):
	time += 1;
	if time % 250 == 0 && !get_tree().is_network_server():
		rpc_id(1, "_time", get_tree().get_network_unique_id(), "ping");
		time = 0;

remote func _time(who, what):
	#print(get_tree().get_rpc_sender_id()," ", who, " ",what);
	pass

func host_server() -> int:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(globals.port, 18) # test-map
	if err == OK:
		get_tree().set_network_peer(peer)
		#checks:
		print("Hosting...This is my ID: ", str(get_tree().get_network_unique_id()))
	return err;

func join_server():
	var peer_join = NetworkedMultiplayerENet.new()
	var err = peer_join.create_client(globals.ip, globals.port)#, 0, 0, 8520) # local-port: needed for NAT-punchtrough
	if err == OK:
		get_tree().set_network_peer(peer_join)
		#checks:
		print("Joining...This is my ID: ", str(get_tree().get_network_unique_id())) 
	return err;

func _player_connected(id): #when someone else connects, I will register the player into my player list dictionary
	print("Hello other players. I just connected and I wont see this message!: ", id)
	#rpc("register_player", get_tree().get_network_unique_id())
	register_player(id)

master func _set_name(player_name):
	var origin = get_tree().get_rpc_sender_id();
	register_player(origin, player_name);

remote func register_player(id, player_name = ""): 
	print("Everyone sees this.. adding this id to your array! ", id, "(",player_name,")") # everyone sees this
	#the server will see this... better tell this guy who else is already in...
	#if !(id in players):
	players[id] = player_name
	
	# Server sends the info of existing players back to the new player
	if get_tree().is_network_server():
		# Send my info to the new player
		rpc_id(id, "register_player", 1, globals.player_name) #rpc_id only targets player with specified ID
		
		# Send the info of existing players to the new player from ther server's personal list
		for peer_id in players:
			rpc_id(id, "register_player", peer_id, players[peer_id]) #rpc_id only targets player with specified ID
		rpc("update_player_list") # not needed, just double checks everyone on same page
	elif players[get_tree().get_network_unique_id()] != globals.player_name:
		rpc("_set_name", globals.player_name);
#Not needed, double check everyone on sme page
remote func update_player_list():
	for x in players:
		print("Player: ", x, " -> ", players[x]);



func _connected_to_server_ok(): 	
	print("(My eyes only)I connected to the server! This is my ID: ", str(get_tree().get_network_unique_id()))
