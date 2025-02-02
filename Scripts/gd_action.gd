class_name GDAction extends MMCAction

var current_rank : int = -1
var current_count : int = -1
var our_hand : Array[int]
var their_hand : Array[int]
var force_pass : bool = false

static func start(hand1 : Array[int], hand2 : Array[int]) -> GDAction:
	var ret_val : GDAction = GDAction.new()
	ret_val.our_hand = hand1
	ret_val.their_hand = hand2
	var opener : Array[int] = ret_val.get_opener()
	ret_val.current_rank = opener[0]
	ret_val.current_count = opener[1]
	ret_val.our_hand = ret_val.our_hand.filter(func(a) : return a != ret_val.current_rank)
	return ret_val

func dump() -> void:
	print("----")
	var d : String = ""
	if force_pass:
		d = "FORCE PASS"
	else:
		d = "(" + str(current_count) + "x" + str(current_rank)+ ")"
	d = dump_hand(our_hand) + " -> " + d
	d = d + " / their hand is " + dump_hand(their_hand)
	print(d)

func dump_hand(hand : Array[int]) -> String:
	hand.sort()
	var ret_val : String = ""
	for i in hand:
		ret_val = ret_val + str(i)
	return ret_val
		

func get_opener() -> Array[int]:
	for i in range(our_hand.max(), 0, -1):
		var count : int = our_hand.count(i)
		if count > 0:
			if count * 2 < i:
				return [i, our_hand.count(i)]
	for i in range(our_hand.max(), 0, -1):
		var count : int = our_hand.count(i)
		if count > 0:
			return [i, count]
	assert(false)
	return [0, 0]

func get_score() -> MMCScore:
	return GDScore.create(self)

func get_followup_moves() -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	if our_hand.is_empty():
		return ret_val
	
	#if force_pass:
		#var potential : GDAction = GDAction.new()
		#potential.our_hand = their_hand
		#potential.their_hand = our_hand
		#potential.current_count = -1
		#potential.current_rank = -1
		#ret_val.append(potential)
	
	if current_rank == -1 or force_pass:
		for i in range(1, their_hand.max() + 1):
			if their_hand.has(i):
				var potential : GDAction = GDAction.new()
				potential.current_count = their_hand.count(i)
				potential.our_hand = their_hand.filter(func(a) : return a != i)
				potential.their_hand = our_hand
				potential.current_rank = i
				ret_val.append(potential)
		if !ret_val.is_empty():
			return ret_val

	for i in range(current_rank, 0, -1):
		var count : int = their_hand.count(i)
		if i < current_rank and count == current_count:
			var potential : GDAction = GDAction.new()
			potential.current_count = their_hand.count(i)
			potential.our_hand = their_hand.filter(func(a) : return a != i)
			potential.their_hand = our_hand
			potential.current_rank = i
			ret_val.append(potential)

	if ret_val.is_empty():
		var potential : GDAction = GDAction.new()
		potential.our_hand = their_hand
		potential.their_hand = our_hand
		potential.current_count = -1
		potential.current_rank = -1
		potential.force_pass = true
		ret_val.append(potential)
	
	return ret_val
