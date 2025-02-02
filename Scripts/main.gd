extends Control

var calc : MinMaxCalculator = MinMaxCalculator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	do_dalmudi()
	#get_tree().quit()

func do_dalmudi() -> void:
	var deck : Array[int]
	for i in range(1, 7):
		for j in range(0, i):
			deck.append(i)
	deck.shuffle()
	var hand1 : Array[int]
	var hand2 : Array[int]
	for i in range(0, deck.size()):
		if i % 2 == 0:
			hand1.append(deck[i])
		else:
			hand2.append(deck[i])
	var action : GDAction = GDAction.start(hand1, hand2)
	action.dump()
	while !action.get_followup_moves().is_empty():
		var counter : GDAction = calc.get_best_action(action)
		counter.dump()
		action = counter
	print("No more follow-up moves")

func do_tic_tac_toe() -> void:
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
