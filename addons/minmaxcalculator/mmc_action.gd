class_name MMCAction extends Object

# TODO: For this to work correctly, this currently needs to return the score from the next player's perspective
func get_score() -> MMCScore:
	# Should evaluate how good the current action leaves the game for the acting player
	# For performance reasons this should be generated when the action was created, or JIT created and left in a quickly parsable format.
	assert(false, "The derived MMCAction class must implement get_score()")
	return null
