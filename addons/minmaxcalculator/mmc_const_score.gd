class_name MMCConstScore extends MMCScore

static func create_highest() -> MMCScore:
	return MMCConstScore.new()
static func create_lowest() -> MMCScore:
	return MMCConstScore.new()

func reversed() -> MMCScore:
	if self == MMCScore.HIGHEST:
		return MMCScore.LOWEST
	else:
		return MMCScore.HIGHEST
