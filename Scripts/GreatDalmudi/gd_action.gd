class_name GDAction extends MMCAction

var rank : int
var score : GDScore

func get_score() -> MMCScore:
	return score

func _to_string() -> String:
	if rank <= 0:
		return "no valid moves, score = " + str(score)
	else:
		return "discard " + str(rank) + "s, score=" + str(score)

#static func start(hand1 : Array[int], hand2 : Array[int]) -> GDAction:
	#var ret_val : GDAction = GDAction.new()
	#ret_val.our_hand = hand1
	#ret_val.their_hand = hand2
	#var opener : Array[int] = ret_val.get_opener()
	#ret_val.current_rank = opener[0]
	#ret_val.current_count = opener[1]
	#ret_val.our_hand = ret_val.our_hand.filter(func(a) : return a != ret_val.current_rank)
	#return ret_val
#
#func dump() -> void:
	#print("----")
	#var d : String = ""
	#if force_pass:
		#d = "FORCE PASS"
	#else:
		#d = "(" + str(current_count) + "x" + str(current_rank)+ ")"
	#d = dump_hand(our_hand) + " -> " + d
	#d = d + " / their hand is " + dump_hand(their_hand)
	#print(d)
#
#func dump_hand(hand : Array[int]) -> String:
	#hand.sort()
	#var ret_val : String = ""
	#for i in hand:
		#ret_val = ret_val + str(i)
	#return ret_val
		#
#
#func get_opener() -> Array[int]:
	#for i in range(our_hand.max(), 0, -1):
		#var count : int = our_hand.count(i)
		#if count > 0:
			#if count * 2 < i:
				#return [i, our_hand.count(i)]
	#for i in range(our_hand.max(), 0, -1):
		#var count : int = our_hand.count(i)
		#if count > 0:
			#return [i, count]
	#assert(false)
	#return [0, 0]
