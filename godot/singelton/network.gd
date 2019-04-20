extends Node

var players = {};

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_to_server_ok")
	if host_server() != OK:
		join_server();

var time = 0;
func _process(delta):
	time += 1;
	if time % 120 == 0 && !get_tree().is_network_server():
		rpc_id(1, "_time", get_tree().get_network_unique_id(), "ping");
		time = 0;

remote func _time(who, what):
	print(get_tree().get_rpc_sender_id()," ", who, " ",what);

func host_server() -> int:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(4242, 18) # test-map
	if err == OK:
		get_tree().set_network_peer(peer)
		#checks:
		print("Hosting...This is my ID: ", str(get_tree().get_network_unique_id()))
	return err;

func join_server():
	var peer_join = NetworkedMultiplayerENet.new()
	peer_join.create_client("127.0.0.1", 4242)
	get_tree().set_network_peer(peer_join)	
	#checks:
	print("Joining...This is my ID: ", str(get_tree().get_network_unique_id())) 

func _player_connected(id): #when someone else connects, I will register the player into my player list dictionary
	print("Hello other players. I just connected and I wont see this message!: ", id)
	#rpc("register_player", get_tree().get_network_unique_id())
	register_player(id)

remote func register_player(id): 
	print("Everyone sees this.. adding this id to your array! ", id) # everyone sees this
	#the server will see this... better tell this guy who else is already in...
	#if !(id in players):
	players[id] = ""
	
	# Server sends the info of existing players back to the new player
	if get_tree().is_network_server():
		# Send my info to the new player
		rpc_id(id, "register_player", 1) #rpc_id only targets player with specified ID
		
		# Send the info of existing players to the new player from ther server's personal list
		for peer_id in players:
			rpc_id(id, "register_player", peer_id) #rpc_id only targets player with specified ID
		rpc("update_player_list") # not needed, just double checks everyone on same page
#Not needed, double check everyone on sme page
remote func update_player_list():
	for x in players:
		print(x)



func _connected_to_server_ok(): 	
	print("(My eyes only)I connected to the server! This is my ID: ", str(get_tree().get_network_unique_id()))
