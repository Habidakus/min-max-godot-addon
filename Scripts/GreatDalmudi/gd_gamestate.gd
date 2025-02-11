class_name GDGameState extends MMCGameState

var player_1_turn : bool = true
var player_1_last_played_a_card : bool = false
var player_1_hand : Array[int]
var player_2_hand : Array[int]
var current_rank : int = -1
var current_count : int = -1

static func create_initial_state(s : int, max_rank : int) -> GDGameState:
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = s
	var deck : Array
	for i in range(1, max_rank + 1):
		for j in range(0, i):
			deck.append([i, rnd.randf()])
	deck.sort_custom(func(a,b) : return a[1] < b[1])
	var ret_val : GDGameState = GDGameState.new()
	for i in range(0, deck.size()):
		if i % 2 == 0:
			ret_val.player_1_hand.append(deck[i][0])
		else:
			ret_val.player_2_hand.append(deck[i][0])
	return ret_val

func _to_string() -> String:
	return dump_current() + " : " + dump_hand(player_1_hand, !player_1_turn) + " / "+ dump_hand(player_2_hand, player_1_turn)

func dump_current() -> String:
	if current_rank == -1:
		return "ANY"
	elif player_1_last_played_a_card == player_1_turn:
		return "PASS"
	else:
		var ret_val : String = ""
		for i in range(0, current_count):
			ret_val = ret_val + str(current_rank)
		return ret_val

func dump_hand(hand : Array[int], just_went : bool) -> String:
	hand.sort()
	var ret_val : String = "(" if just_went else ""
	for i in hand:
		ret_val = ret_val + str(i)
	if just_went:
		ret_val = ret_val + ")"
	return ret_val

func apply_action(action : MMCAction) -> MMCGameState:
	var ret_val : GDGameState = GDGameState.new()
	if action.rank != -1:
		if player_1_turn:
			ret_val.current_count = player_1_hand.count(action.rank)
			ret_val.player_1_hand = player_1_hand.filter(func(a) : return a != action.rank)
			ret_val.player_2_hand = player_2_hand
			ret_val.player_1_last_played_a_card = true
		else:
			ret_val.current_count = player_2_hand.count(action.rank)
			ret_val.player_1_hand = player_1_hand
			ret_val.player_2_hand = player_2_hand.filter(func(a) : return a != action.rank)
			ret_val.player_1_last_played_a_card = false
		ret_val.current_rank = action.rank
	else:
		for card in player_1_hand:
			ret_val.player_1_hand.append(card)
		for card in player_2_hand:
			ret_val.player_2_hand.append(card)
		ret_val.player_1_last_played_a_card = player_1_last_played_a_card
		ret_val.current_count = current_count
		ret_val.current_rank = current_rank
	ret_val.player_1_turn = !player_1_turn
	return ret_val

func must_pass(moves : Array[MMCAction]) -> bool:
	if moves.is_empty():
		return true
	if moves.size() == 1:
		return (moves[0] as GDAction).rank <= 0
	return false

func get_moves() -> Array[MMCAction]:
	if player_1_hand.is_empty() or player_2_hand.is_empty():
		return []
	if player_1_turn:
		return get_hand_moves(player_1_hand, player_1_last_played_a_card)
	else:
		return get_hand_moves(player_2_hand, !player_1_last_played_a_card)

func get_hand_moves(hand : Array[int], can_restart : bool) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	if current_rank == -1:
		for i in range(1, hand.max() + 1):
			if hand.has(i):
				var potential : GDAction = GDAction.new()
				potential.rank = i
				potential.score = GDScore.create(apply_action(potential))
				ret_val.append(potential)
		assert(!ret_val.is_empty())
		return ret_val

	for i in range(1, current_rank):
		if hand.count(i) == current_count:
			var potential : GDAction = GDAction.new()
			potential.rank = i
			potential.score = GDScore.create(apply_action(potential))
			ret_val.append(potential)

	if ret_val.is_empty():
		if can_restart:
			for i in range(1, hand.max() + 1):
				if hand.has(i):
					var potential : GDAction = GDAction.new()
					potential.rank = i
					potential.score = GDScore.create(apply_action(potential))
					ret_val.append(potential)
			assert(!ret_val.is_empty())
			return ret_val
		else:
			var potential : GDAction = GDAction.new()
			potential.rank = -1 # Sentinel value for pass
			potential.score = GDScore.create(apply_action(potential))
			ret_val.append(potential)
	
	return ret_val
	
func get_score() -> MMCScore:
	return GDScore.create(self)
