class_name MMCScore extends Object

func reversed() -> MMCScore:
	assert("The derived MMCScore class must implement reversed()")
	return null
	
func is_better_than(other : MMCScore) -> bool:
	assert("The derived MMCScore class must implement is_better_than()")
	return false

# Provided your derived class implements is_better_than() you do not need
# to implement the following function
func is_better_than_or_equal(other : MMCScore) -> bool:
	return !other.is_better_than(self)
