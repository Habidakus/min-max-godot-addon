extends StateMachineState

var cells : Array[Label]
var calc : MinMaxCalculator = MinMaxCalculator.new()
var ended : bool = false
var continue_label : Label = null

func _ready() -> void:
	call_deferred("init")

func init() -> void:
	var grid = find_child("GridContainer") as GridContainer
	continue_label = find_child("Continue") as Label
	assert(continue_label)
	continue_label.hide()
	cells.clear()
	for cell in grid.get_children():
		if cell is ColorRect:
			var label : Label = cell.get_child(0) as Label
			cells.append(label)
			var color_rect : ColorRect = cell
			color_rect.mouse_entered.connect(Callable(self, "mouse_entered").bind(color_rect))
			color_rect.mouse_exited.connect(Callable(self, "mouse_exit").bind(color_rect))
			color_rect.gui_input.connect(Callable(self, "gui_input").bind(color_rect))

func enter_state() -> void:
	super.enter_state()
	ended = false
	var grid = find_child("GridContainer") as GridContainer
	for cell in grid.get_children():
		if cell is ColorRect:
			var label : Label = cell.get_child(0) as Label
			label.text = ""
			var color_rect : ColorRect = cell
			color_rect.color = Color.BLACK

func mouse_entered(color_rect : ColorRect) -> void:
	var label : Label = color_rect.get_child(0) as Label
	if ended == false and label.text.is_empty():
		color_rect.color = Color.SLATE_GRAY

func mouse_exit(color_rect : ColorRect) -> void:
	var label : Label = color_rect.get_child(0) as Label
	if ended == false and label.text.is_empty():
		color_rect.color = Color.BLACK

func generate_game_state(human_turn : bool) -> TTTGameState:
	var game_state : TTTGameState = TTTGameState.new()
	game_state.xs_turn = human_turn
	for cell : Label in cells:
		if cell.text.is_empty():
			game_state.squares.append(0)
		elif cell.text == "X":
			game_state.squares.append(1)
		elif cell.text == "O":
			game_state.squares.append(-1)
		else:
			assert(false)
	return game_state

func run_ai() -> void:
	var action : TTTAction = calc.get_best_action(generate_game_state(false))
	var label : Label = cells[action.square]
	assert(label.text.is_empty())
	label.text = "O"
	label.get_parent().color = Color.DIM_GRAY
	if generate_game_state(true).is_ended():
		ended = true
		continue_label.show()

func _input(event : InputEvent) -> void:
	if ended:
		if event is InputEventKey:
			if event.is_released():
				our_state_machine.switch_state("State_Menu")
	
func gui_input(event: InputEvent, color_rect : ColorRect) -> void:
	if ended:
		return

	if event is InputEventMouseButton:
		var iemb : InputEventMouseButton = event as InputEventMouseButton
		if iemb.is_released():
			var label : Label = color_rect.get_child(0) as Label
			if label.text.is_empty():
				label.text = "X"
				color_rect.color = Color.DIM_GRAY
				var game_state : TTTGameState = generate_game_state(false)
				if game_state.is_ended():
					ended = true
					continue_label.show()
				else:
					run_ai()
