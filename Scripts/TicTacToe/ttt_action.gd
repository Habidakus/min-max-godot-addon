class_name TTTAction extends MMCAction

var square : int = 0
var score : TTTScore = null

#static func start(x : int, y : int) -> TTTAction:
	#var ret_val : TTTAction = TTTAction.new()
	#ret_val.xs_turn = true
	#ret_val.squares[x + y * 3] = 1
	#return ret_val
#

func _to_string() -> String:
	return "square=" + str(square) + ", score=" + str(score)

func get_score() -> MMCScore:
	return score

#func get_followup_moves() -> Array[MMCAction]:
	#var place_value : int = -1 if xs_turn else 1
	#var ret_val : Array[MMCAction]
	#for i in squares.size():
		#if squares[i] == 0:
			#var opponent_move : TTTAction = TTTAction.new()
			#opponent_move.xs_turn = xs_turn == false
			#for j in squares.size():
				#opponent_move.squares[j] = squares[j]
			#opponent_move.squares[i] = place_value
			#ret_val.append(opponent_move)
	#return ret_val
