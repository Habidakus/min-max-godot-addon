class_name MMCScore extends Object

static var HIGHEST : MMCScore = MMCConstScore.create_highest()
static var LOWEST : MMCScore = MMCConstScore.create_lowest()

func reversed() -> MMCScore:
	assert(false, "The derived MMCScore class must implement reversed()")
	return null
	
func is_better_than(other : MMCScore) -> bool:
	assert(false, "The derived MMCScore class must implement is_better_than()")
	return false

static func is_first_better_than_second(first : MMCScore, second : MMCScore) -> bool:
	if second == HIGHEST:
		return false
	if first == LOWEST:
		return false
	if first == HIGHEST:
		return true
	if second == LOWEST:
		return true
	return first.is_better_than(second)
	
static func is_first_better_than_or_equal_to_second(first : MMCScore, second : MMCScore) -> bool:
	if first == HIGHEST:
		return true
	if second == LOWEST:
		return true
	if second == HIGHEST:
		return false
	if first == LOWEST:
		return false
	return !second.is_better_than(first)
