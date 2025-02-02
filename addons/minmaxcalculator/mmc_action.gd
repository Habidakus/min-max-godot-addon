class_name MMCAction extends Object

func get_score() -> MMCScore:
	# Should evaluate how good the current action leaves the game for the acting player
	assert("The derived MMCAction class must implement get_score()")
	return null

func get_followup_moves() -> Array[MMCAction]:
	assert("The derived MMCAction class must implement get_followup_moves()")
	return []
