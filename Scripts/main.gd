extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var calc = MinMaxCalculator.new()
	#for x in range(0, 3):
		#for y in range(0, 3):
			#var action : TTTAction = TTTAction.start(x, y)
			#var counter : TTTAction = calc.get_best_action(action)
			#counter.dump()
	var action : TTTAction = TTTAction.start(0, 0)
	action.dump()
	while action.get_followup_moves().size() > 0:
		var counter : TTTAction = calc.get_best_action(action)
		counter.dump()
		action = counter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
