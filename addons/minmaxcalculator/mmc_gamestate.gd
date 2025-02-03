class_name MMCGameState extends Object

func apply_action(action : MMCAction) -> MMCGameState:
	# Should create a new game state that reflects how the given action changed the board
	assert("The derived MMCGameState class must implement apply_action()")
	return null

func get_moves() -> Array[MMCAction]:
	assert("The derived MMCGameState class must implement get_moves()")
	return []

func get_score_for_current_player() -> MMCScore:
	assert("The derived MMCGameState class must implement get_score()")
	return null
