class_name MMCDebug extends Object

var all_game_states : Dictionary # key = MMCGameState, value = Dictionary<Action, [Score, GameState]>

func add_actions(game_state : MMCGameState, actions : Array[MMCAction]) -> void:
	var gsactions : Dictionary
	for action : MMCAction in actions:
		gsactions[action] = []
	if all_game_states.has(game_state):
		print("WAHT?")
	else:
		all_game_states[game_state] = gsactions

func add_result(game_state : MMCGameState, action : MMCAction, result_state : MMCGameState, score : MMCScore) -> void:
	if all_game_states.has(game_state):
		if all_game_states[game_state].has(action):
			all_game_states[game_state][action] = [score, result_state]
		else:
			print("MMCDebug[" + str(game_state) + "] has no action: " + str(action))
	else:
		print("NO GAME STATE FOUND in MMCDebug: " + str(game_state))

func indent(index : int) -> String:
	var ret_val : String = ""
	for i in range(0, index):
		ret_val += " "
	return ret_val

func dump(game_state : MMCGameState) -> void:
	print(str(game_state))
	var action_dict : Dictionary = all_game_states[game_state]
	if action_dict.is_empty():
		print(indent(1) + "NO ACTIONS")
		return

	for action in action_dict.keys():
		var tupple : Array = action_dict[action]
		if tupple.is_empty():
			print(indent(1) + str(action) + " : not evaluated")
		else:
			print(indent(1) + str(action) + " vvv")
			dump_internal(2, tupple[0], tupple[1])

func dump_internal(ind : int, score : MMCScore, game_state : MMCGameState) -> void:
	print(indent(ind) + str(game_state))
	
	var action_dict : Dictionary = all_game_states[game_state]
	if action_dict.is_empty():
		print(indent(ind + 1) + "NO ACTIONS")
		return
		
	for action in action_dict.keys():
		var tupple : Array = action_dict[action]
		if tupple.is_empty():
			print(indent(ind + 1) + str(action) + " : not evaluated")
		else:
			print(indent(ind + 1) + str(action) + " vvv")
			dump_internal(ind + 2, tupple[0], tupple[1])
