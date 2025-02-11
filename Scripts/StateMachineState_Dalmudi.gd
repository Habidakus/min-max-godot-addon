extends StateMachineState

var hand_ai : ColorRect
var hand_player : ColorRect
var discard_area : ColorRect
var pass_button : Button
var continue_label : Label
var game_over_label : Label
var cards : Array[Card]
var ended : bool = false
var cards_moving : bool = false
var calc : MinMaxCalculator = MinMaxCalculator.new()
var pending_ai_move : MMCAction = null
var player_who_last_played : int = 0
var current_rank : int = -1
var current_count : int = -1

const max_rank : int = 7
const side_border : int = 48
const initial_seed : int = -1

var card_scene : Resource = preload("res://Scenes/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("init")

func init() -> void:
	hand_ai = find_child("Hand_AI") as ColorRect
	hand_player = find_child("Hand_Player") as ColorRect
	discard_area = find_child("Discard_Area") as ColorRect
	continue_label = find_child("Continue") as Label
	game_over_label = find_child("GameOver") as Label
	assert(game_over_label)
	game_over_label.hide()
	pass_button = find_child("PassButton") as Button
	assert(continue_label)
	continue_label.hide()
	cards.clear()
	for rank in range(1, max_rank + 1):
		for c in range(1, rank+1):
			var card : Card = card_scene.instantiate()
			card.set_rank(rank)
			cards.append(card)
			add_child(card)
			var color_rect : ColorRect = card.get_child(0) as ColorRect
			color_rect.mouse_entered.connect(Callable(self, "mouse_entered").bind(card))
			color_rect.mouse_exited.connect(Callable(self, "mouse_exit").bind(card))
			color_rect.gui_input.connect(Callable(self, "gui_input").bind(card))

func get_current_game_state() -> GDGameState:
	var ret_val : GDGameState = GDGameState.new()
	ret_val.current_count = current_count
	ret_val.current_rank = current_rank
	ret_val.player_1_last_played_a_card = true if player_who_last_played == 1 else false

	for card : Card in cards:
		if card.player == 1:
			ret_val.player_1_hand.append(card.rank)
		elif card.player == 2:
			ret_val.player_2_hand.append(card.rank)
	return ret_val

func mouse_entered(mouse_card : Card) -> void:
	if ended or cards_moving:
		return
	if mouse_card.player != 2:
		return
	if pending_ai_move != null:
		return
	var game_state : GDGameState = get_current_game_state()
	game_state.player_1_turn = false
	var possible_moves : Array[MMCAction] = game_state.get_moves()
	var valid_move : bool = false
	for move : MMCAction in possible_moves:
		if (move as GDAction).rank == mouse_card.rank:
			valid_move = true
	for iter_card : Card in cards:
		if iter_card.matches_card(mouse_card):
			var color_rect : ColorRect = iter_card.get_child(0) as ColorRect
			color_rect.color = Color.GREEN if valid_move else Color.RED
	
func mouse_exit(mouse_card : Card) -> void:
	if ended or cards_moving:
		return
	if mouse_card.player != 2:
		return
	if pending_ai_move != null:
		return
	for iter_card : Card in cards:
		if iter_card.matches_hand(mouse_card.player):
			var color_rect : ColorRect = iter_card.get_child(0) as ColorRect
			color_rect.color = Color.BLACK

func move_ai_cards() -> void:
	assert(pending_ai_move != null)
	pass_button.hide()
	
	var card_y_line : float = discard_area.global_position.y + discard_area.size.y / 2
	var card_x_start : float = discard_area.global_position.x + side_border
	var card_x_end : float = discard_area.global_position.x + discard_area.size.x - side_border
	
	var move : GDAction = pending_ai_move as GDAction
	var new_count : int = 0
	for iter_card : Card in cards:
		if iter_card.matches_rank_and_player(move.rank, 1):
			new_count += 1

	hide_discards()

	pending_ai_move = null
	current_count = new_count
	current_rank = move.rank
	player_who_last_played = 1

	var index : int = 0
	for iter_card : Card in cards:
		if iter_card.matches_rank_and_player(current_rank, 1):
			
			var color_rect : ColorRect = iter_card.get_child(0) as ColorRect
			color_rect.color = Color.BLACK
			
			var frac : float = 0.5
			if current_count > 1:
				frac = float(index) / float(current_count - 1)
			iter_card.discard(Vector2(lerpf(card_x_start, card_x_end, frac), card_y_line))
			index += 1
	cards_moving = true
	
	var game_state : GDGameState = get_current_game_state()
	game_state.player_1_turn = false
	var moves : Array[MMCAction] = game_state.get_moves()
	if moves.is_empty():
		var score : MMCScore = game_state.get_score()
		var game_over_text : String = "Victory" if score.is_better_than(score.reversed()) else "Loss"
		show_game_over(game_over_text)
	elif game_state.must_pass(moves):
		pass_button.show()

func _input(event : InputEvent) -> void:
	if ended:
		if event is InputEventKey:
			if event.is_released():
				our_state_machine.switch_state("State_Menu")

func show_game_over(text : String) -> void:
	pass_button.hide()
	game_over_label.text = text
	game_over_label.show()
	continue_label.show()
	ended = true

func hide_discards() -> void:
	for card : Card in cards:
		if card.player == 0 && card.visible == true:
			card.hide()
			card.set_pending_pos(Vector2(-100, -100))

func gui_input(event: InputEvent, mouse_card : Card) -> void:
	if ended or cards_moving:
		return
	if pending_ai_move != null:
		return
	if !event is InputEventMouseButton:
		return
	var iemb : InputEventMouseButton = event as InputEventMouseButton
	if !iemb.is_released():
		return
	if mouse_card.player != 2:
		return
	var game_state : GDGameState = get_current_game_state()
	game_state.player_1_turn = false
	var possible_moves : Array[MMCAction] = game_state.get_moves()
	var valid_move : bool = false
	for move : MMCAction in possible_moves:
		if (move as GDAction).rank == mouse_card.rank:
			valid_move = true
	if valid_move == false:
		return
	
	var card_y_line : float = discard_area.global_position.y + discard_area.size.y / 2
	var card_x_start : float = discard_area.global_position.x + side_border
	var card_x_end : float = discard_area.global_position.x + discard_area.size.x - side_border
	
	var new_count : int = 0
	for iter_card : Card in cards:
		if iter_card.matches_card(mouse_card):
			new_count += 1

	hide_discards()

	current_count = new_count
	current_rank = mouse_card.rank
	player_who_last_played = 2
	
	var index : int = 0
	for iter_card : Card in cards:
		if iter_card.matches_rank_and_player(current_rank, 2):
			
			var color_rect : ColorRect = iter_card.get_child(0) as ColorRect
			color_rect.color = Color.BLACK
			
			var frac : float = 0.5
			if current_count > 1:
				frac = float(index) / float(current_count - 1)
			iter_card.discard(Vector2(lerpf(card_x_start, card_x_end, frac), card_y_line))
			index += 1
	cards_moving = true
	
	game_state = get_current_game_state()
	game_state.player_1_turn = true
	var moves : Array[MMCAction] = game_state.get_moves()
	if moves.is_empty():
		var score : MMCScore = game_state.get_score()
		var game_over_text : String = "Loss" if score.is_better_than(score.reversed()) else "Victory"
		show_game_over(game_over_text)
	else:
		pending_ai_move = calc.get_best_action(game_state)

func _process(_delta: float) -> void:
	cards_moving = false
	place_cards_hand(1)
	place_cards_hand(2)
	if cards_moving == false && pending_ai_move != null:
		move_ai_cards()

func place_cards_hand(hand : int) -> void:
	var count : int = 0
	for card : Card in cards:
		if card.player == hand:
			count += 1

	var card_x_start : float
	var card_x_end : float
	var card_y_line : float
	if hand == 1:
		card_y_line = hand_ai.global_position.y + hand_ai.size.y / 2
		card_x_start = hand_ai.global_position.x + side_border
		card_x_end = hand_ai.global_position.x + hand_ai.size.x - side_border
	else:
		card_y_line = hand_player.global_position.y + hand_player.size.y / 2
		card_x_start = hand_player.global_position.x + side_border
		card_x_end = hand_player.global_position.x + hand_player.size.x - side_border

	var index : int = 0
	for card : Card in cards:
		if card.player == hand:
			var frac : float = 0.5
			if count > 1:
				frac = float(index) / float(count - 1)
			if card.set_pending_pos(Vector2(lerpf(card_x_start, card_x_end, frac), card_y_line)):
				cards_moving = true
			index += 1

func enter_state() -> void:
	super.enter_state()
	pass_button.hide()
	continue_label.hide()
	game_over_label.hide()
	ended = false
	current_count = -1
	current_rank = -1
	player_who_last_played = 0
	pending_ai_move = null
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	if initial_seed == -1:
		rnd.seed = int(Time.get_unix_time_from_system())
	else:
		rnd.seed = initial_seed
	for card : Card in cards:
		var color_rect : ColorRect = card.get_child(0) as ColorRect
		color_rect.color = Color.BLACK
		card.sort_order = rnd.randf()
	cards.sort_custom(func(a,b) : return a.sort_order < b.sort_order)
	var index : int = 0
	for card : Card in cards:
		index += 1
		card.player = 1 + (index % 2)
		card.global_position = size / 2
		card.show()
	cards.sort_custom(func(a, b) : return a.rank < b.rank)

func _on_pass_turn_button_up() -> void:
	var game_state : GDGameState = get_current_game_state()
	game_state.player_1_turn = true
	var moves : Array[MMCAction] = game_state.get_moves()
	if moves.is_empty():
		var score : MMCScore = game_state.get_score()
		var game_over_text : String = "Loss" if score.is_better_than(score.reversed()) else "Victory"
		show_game_over(game_over_text)
	else:
		pending_ai_move = calc.get_best_action(game_state)
