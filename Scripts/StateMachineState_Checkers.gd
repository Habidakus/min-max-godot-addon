class_name SMSCheckers extends StateMachineState

enum CurrentTurn { NoOne, Player, AI }

var current_turn : CurrentTurn = CurrentTurn.NoOne
var board : GridContainer
var pieces : Array[Checker]
var checkers_state_machine : StateMachine

var checker_scene : Resource = preload("res://Scenes/checker.tscn")

const board_size : int = 8

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
	var mouse_entered_callback = Callable(self, "checker_mouse_entered")
	var mouse_exited_callback = Callable(self, "checker_mouse_exited")
	var input_event_callback = Callable(self, "checker_input_event")
	for x in range(0, board_size):
		for y in range(0, board_size):
			var player : int = 0
			if y < 3:
				player = 1
			elif y > 4:
				player = 2
			var square : ColorRect = ColorRect.new()
			#square.mouse_filter = Control.MOUSE_FILTER_IGNORE
			setup_callbacks(square, mouse_entered_callback, mouse_exited_callback, input_event_callback)
			square.set_meta("loc", Vector2i(x, y))
			if x % 2 == y % 2:
				square.color = Color.ROSY_BROWN
			else:
				square.color = Color.SADDLE_BROWN
				if player != 0:
					var checker : Checker = checker_scene.instantiate()
					pieces.append(checker)
					add_child(checker)
			square.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			square.size_flags_vertical = Control.SIZE_EXPAND_FILL
			board.add_child(square)

func checker_mouse_entered(square : ColorRect) -> void:
	var square_loc : Vector2i = square.get_meta("loc") as Vector2i
	if current_turn == CurrentTurn.Player:
		for checker : Checker in pieces:
			if checker.side == 2:
				if checker.square == square_loc:
					checker.highlight(Color.GREEN)
					return

func checker_mouse_exited(square : ColorRect) -> void:
	var square_loc : Vector2i = square.get_meta("loc") as Vector2i
	if current_turn == CurrentTurn.Player:
		for checker : Checker in pieces:
			if checker.square == square_loc:
				checker.set_default_color()
				return

func checker_input_event(event : InputEvent, square : ColorRect) -> void:
	if event is InputEventMouseButton:
		var iemb : InputEventMouseButton = event as InputEventMouseButton
		if iemb.is_pressed():
			checkers_state_machine.switch_state("State_HumanHandOnPiece")

func enter_state() -> void:
	super.enter_state()
	
	current_turn = CurrentTurn.NoOne
	var index : int = 0
	for x in range(0, board_size):
		for y in range(0, board_size):
			if x % 2 == y % 2:
				continue

			var player : int = 0
			var dir : int = 0
			if x < 3:
				player = 1
				dir = 1
			elif x > 4:
				player = 2
				dir = -1
			else:
				continue
				
			var checker : Checker = pieces[index]
			checker.init(x, y, dir, player)
			index += 1

func move_pieces(delta : float) -> bool:
	var still_moving : bool = false
	for checker : Checker in pieces:
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
