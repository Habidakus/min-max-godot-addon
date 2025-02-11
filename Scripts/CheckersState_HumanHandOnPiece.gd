class_name SMSHumanHandOnPiece extends StateMachineState

var current_checker : Checker
var possible_moves : Array[CAction]
var game_manager : SMSCheckers
var checker_released_callable : Callable
var square_size : Vector2
var active_move_color : Color = Color.BLUE
var other_move_color : Color = Color(Color.SKY_BLUE, 0.33)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checker_released_callable = Callable(self, "checker_released")

func init(sms_checkers : SMSCheckers) -> void:
	game_manager = sms_checkers

func get_move_closest_to_mouse() -> CAction:
	var global_mouse_pos : Vector2 = get_global_mouse_position()
	var ret_val : CAction = null
	var best_dist : float = -1
	for move : CAction in possible_moves:
		var last_pos : Vector2i = move.get_final_location()
		var delta : Vector2 = Vector2(last_pos.x - current_checker.square.x, last_pos.y - current_checker.square.y) * square_size
		var move_end_global_pos = delta + current_checker.global_position
		var dist_squared = (global_mouse_pos - move_end_global_pos).length_squared()
		if best_dist < 0 || dist_squared < best_dist:
			best_dist = dist_squared
			ret_val = move
	return ret_val

func draw_move(move : CAction, active_move : bool) -> void:
	var last_cursor : Vector2 = move.checker.global_position
	var color : Color = active_move_color if active_move else other_move_color
	for move_square : Vector2i in move.moves:
		var new_cursor : Vector2 = last_cursor + Vector2(move_square.x - current_checker.square.x, move_square.y - current_checker.square.y) * square_size
		self.draw_line(last_cursor, new_cursor, color, 5, true)
		self.draw_circle(new_cursor, 15, color, true)

func _draw() -> void:
	if possible_moves != null:
		var move_closest_to_mouse : CAction = get_move_closest_to_mouse()
		for move : CAction in possible_moves:
			if move != move_closest_to_mouse:
				draw_move(move, false)
		draw_move(move_closest_to_mouse, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()

func set_checker(ss : Vector2, checker : Checker, moves : Array[CAction]) -> void:
	assert(current_checker == null)
	current_checker = checker
	possible_moves = moves
	square_size = ss

func checker_released(_checker : Checker) -> void:
	game_manager.commit_move(get_move_closest_to_mouse())

func enter_state() -> void:
	super.enter_state()
	current_checker.highlight(active_move_color)
	game_manager.checker_released.connect(checker_released_callable)

func exit_state(next_state: StateMachineState) -> void:
	game_manager.checker_released.disconnect(checker_released_callable)
	current_checker.set_default_color()
	current_checker = null
	super.exit_state(next_state)
