class_name SMSCheckers extends StateMachineState

enum CurrentTurn { NoOne, Player, AI }

var current_turn : CurrentTurn = CurrentTurn.NoOne
var board : GridContainer
var pieces : Array[Checker]
var checkers_state_machine : StateMachine
var calc : MinMaxCalculator = MinMaxCalculator.new()

var checker_scene : Resource = preload("res://Scenes/checker.tscn")

signal checker_entered
signal checker_exited
signal checker_pressed
signal checker_released

const board_size : int = 8

func generate_game_state() -> CGameState:
	var ret_val : CGameState = CGameState.create(board_size, pieces, current_turn != CurrentTurn.AI)
	return ret_val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkers_state_machine = find_child("CheckersStateMachine") as StateMachine
	board = find_child("GridContainer") as GridContainer
	call_deferred("init")

func setup_callbacks(square : ColorRect, mouse_entered_callback : Callable, mouse_exited_callback : Callable, input_event_callback : Callable) -> void:
	square.mouse_entered.connect(mouse_entered_callback.bind(square))
	square.mouse_exited.connect(mouse_exited_callback.bind(square))
	square.gui_input.connect(input_event_callback.bind(square))

func init() -> void:
	find_child("State_PiecesMoving").init(self)
	find_child("State_ComputerTurn").init(self)
	var human_turn_state : SMSHumanTurn = find_child("State_HumanTurn") as SMSHumanTurn
	human_turn_state.init(self)
	var human_hand_on_piece_state : SMSHumanHandOnPiece = find_child("State_HumanHandOnPiece") as SMSHumanHandOnPiece
	human_hand_on_piece_state.init(self)
	var mouse_entered_callback = Callable(self, "checker_mouse_entered")
	var mouse_exited_callback = Callable(self, "checker_mouse_exited")
	var input_event_callback = Callable(self, "checker_input_event")
	for y in range(0, board_size):
		for x in range(0, board_size):
			var square : ColorRect = ColorRect.new()
			#square.mouse_filter = Control.MOUSE_FILTER_IGNORE
			setup_callbacks(square, mouse_entered_callback, mouse_exited_callback, input_event_callback)
			square.set_meta("loc", Vector2i(x, y))
			if x % 2 == y % 2:
				square.color = Color.ROSY_BROWN
			else:
				square.color = Color.SADDLE_BROWN
				if y < 3 || y > 4:
					var checker : Checker = checker_scene.instantiate()
					pieces.append(checker)
					add_child(checker)
			square.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			square.size_flags_vertical = Control.SIZE_EXPAND_FILL
			board.add_child(square)

func checker_mouse_entered(square : ColorRect) -> void:
	var square_loc : Vector2i = square.get_meta("loc") as Vector2i
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if checker.side == 2:
			if checker.square == square_loc:
				checker_entered.emit(checker)
				return

func checker_mouse_exited(square : ColorRect) -> void:
	var square_loc : Vector2i = square.get_meta("loc") as Vector2i
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if checker.square == square_loc:
			checker_exited.emit(checker)
			return

func checker_input_event(event : InputEvent, square : ColorRect) -> void:
	if event is InputEventMouseButton:
		var iemb : InputEventMouseButton = event as InputEventMouseButton
		if iemb.is_pressed() || iemb.is_released():
			var square_loc : Vector2i = square.get_meta("loc") as Vector2i
			for checker : Checker in pieces:
				if checker.alive == false:
					continue
				if checker.square == square_loc:
					if iemb.is_pressed():
						checker_pressed.emit(checker)
					elif iemb.is_released():
						checker_released.emit(checker)
					else:
						assert(false)
					return

func enter_state() -> void:
	super.enter_state()
	
	current_turn = CurrentTurn.NoOne
	var index : int = 0
	for y in range(0, board_size):
		for x in range(0, board_size):
			if x % 2 == y % 2:
				continue

			var player : int = 0
			var dir : int = 0
			if y < 3:
				player = 1
				dir = 1
			elif y > 4:
				player = 2
				dir = -1
			else:
				continue
				
			var checker : Checker = pieces[index]
			checker.init(x, y, dir, player)
			index += 1

func commit_move(move : CAction) -> void:
	if move == null || move.moves.is_empty():
		checkers_state_machine.switch_state("State_GameOver")
	else:
		#var pre_move_score : CScore = CScore.create(generate_game_state())
		#var pre_move_loc : Vector2i = move.checker.square
		move.checker.square = move.get_final_location()
		if move.foe != null:
			move.foe.kill()
		#if move.game_state.human_turn == false:
			#var post_move_score : CScore = CScore.create(generate_game_state())
			#if pre_move_score.is_better_than(post_move_score):
				#print("AI Move made the human's position worse (" + str(pre_move_loc) + " to " + str(move.checker.square) + ")")
				#print(str(pre_move_score) + " > " + str(post_move_score))
			#elif post_move_score.is_better_than(pre_move_score):
				#print("AI Move made the human's position better (" + str(pre_move_loc) + " to " + str(move.checker.square) + ")")
				#print(str(pre_move_score) + " < " + str(post_move_score))
			#else:
				#print("AI move (" + str(pre_move_loc) + " to " + str(move.checker.square) + ") is neutral from the human's perspective")
				#print(str(pre_move_score) + " == " + str(post_move_score))
		checkers_state_machine.switch_state("State_PiecesMoving")

func get_square_size() -> Vector2:
	return board.get_child(board_size + 1).position - board.get_child(0).position

func move_pieces(delta : float) -> bool:
	var still_moving : bool = false
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if checker.move(board, delta):
			still_moving = true
	return still_moving

func transition_to_next_turn() -> void:
	if current_turn == CurrentTurn.Player:
		current_turn = CurrentTurn.AI
		checkers_state_machine.switch_state("State_ComputerTurn")
	else:
		current_turn = CurrentTurn.Player
		checkers_state_machine.switch_state("State_HumanTurn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if checkers_state_machine.current_state == checkers_state_machine.initial_state:
		checkers_state_machine.switch_state("State_PiecesMoving")
