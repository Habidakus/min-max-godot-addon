class_name SMSHumanTurn extends StateMachineState

var game_manager : SMSCheckers
var checker_entered_callable : Callable
var checker_exited_callable : Callable
var checker_pressed_callable : Callable
var checker_released_callable : Callable
var hover_checker : Checker
#var game_state : CGameState
var squares_and_moves : Dictionary # dict<checker, Array[CActions]>

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checker_entered_callable = Callable(self, "checker_entered")
	checker_exited_callable = Callable(self, "checker_exited")
	checker_pressed_callable = Callable(self, "checker_pressed")
	checker_released_callable = Callable(self, "checker_released")
	
func init(sms_checkers : SMSCheckers) -> void:
	game_manager = sms_checkers

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func enter_state() -> void:
	super.enter_state()
	game_manager.checker_entered.connect(checker_entered_callable)
	game_manager.checker_exited.connect(checker_exited_callable)
	game_manager.checker_pressed.connect(checker_pressed_callable)
	game_manager.checker_released.connect(checker_released_callable)
	var game_state : CGameState = game_manager.generate_game_state()
	var moves : Array[MMCAction] = game_state.get_moves()
	if moves == null || moves.is_empty():
		game_manager.checkers_state_machine.switch_state("State_GameOver")
	else:
		for move : MMCAction in moves:
			assert(move is CAction)
			var m : CAction = move as CAction
			if squares_and_moves.has(m.checker):
				squares_and_moves[m.checker].append(m)
			else:
				var marray : Array[CAction]
				marray.append(m)
				squares_and_moves[m.checker] = marray
	
func exit_state(next_state: StateMachineState) -> void:
	game_manager.checker_entered.disconnect(checker_entered_callable)
	game_manager.checker_exited.disconnect(checker_exited_callable)
	game_manager.checker_pressed.disconnect(checker_pressed_callable)
	game_manager.checker_released.disconnect(checker_released_callable)
	if hover_checker != null:
		hover_checker.set_default_color()
		hover_checker = null
	squares_and_moves.clear()
	super.exit_state(next_state)

func checker_entered(checker: Checker) -> void:
	if squares_and_moves.has(checker):
		checker.highlight(Color.GREEN)
		assert(hover_checker == null)
		hover_checker = checker

func checker_exited(checker: Checker) -> void:
	checker.set_default_color()
	if hover_checker == checker:
		hover_checker = null

func checker_pressed(checker : Checker) -> void:
	if squares_and_moves.has(checker):
		var hhop : SMSHumanHandOnPiece = game_manager.find_child("State_HumanHandOnPiece") as SMSHumanHandOnPiece
		hhop.set_checker(game_manager.get_square_size(), checker, squares_and_moves[checker])
		game_manager.checkers_state_machine.switch_state(hhop.name)

func checker_released(_checker : Checker) -> void:
	pass
	#game_manager.checkers_state_machine.switch_state("State_HumanTurn")
