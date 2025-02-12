class_name CGameState extends MMCGameState

var human_turn : bool
var pieces : Array[Checker]
var board_size : int

static func create(size : int, checkers : Array[Checker], human_is_active : bool) -> CGameState:
	var ret_val : CGameState = CGameState.new()
	ret_val.human_turn = human_is_active
	ret_val.pieces = checkers
	ret_val.board_size = size
	return ret_val

func apply_action(action : MMCAction) -> MMCGameState:
	var ret_val : CGameState = CGameState.new()
	ret_val.human_turn = !human_turn
	ret_val.board_size = board_size
	var move : CAction = action as CAction
	for checker : Checker in pieces:
		var clone : Checker = checker.clone()
		if checker == move.checker:
			clone.square = move.get_final_location()
		elif move.foes.has(checker):
			clone.kill()
		ret_val.pieces.append(clone)
	return ret_val

enum SquareContents { invalid, empty, enemy, ally }
func get_contents(square : Vector2i, side : int) -> SquareContents:
	if square.x < 0 || square.x >= board_size:
		return SquareContents.invalid
	if square.y < 0 || square.y >= board_size:
		return SquareContents.invalid
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if checker.square == square:
			if checker.side == side:
				return SquareContents.ally
			else:
				return SquareContents.enemy
	return SquareContents.empty

func get_checker(square : Vector2i) -> Checker:
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if checker.square == square:
			return checker
	return null

func get_moves_in_direction(checker : Checker, dir : Vector2i) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	var dest = checker.square + dir
	var dest_contents : SquareContents = get_contents(dest, checker.side)
	if dest_contents == SquareContents.invalid || dest_contents == SquareContents.ally:
		return ret_val
	if dest_contents == SquareContents.empty:
		ret_val.append(CAction.create_move(checker, dest, self))
		return ret_val
	var list_of_multi_hops : Array[Array] = get_multi_hops(checker, get_checker(dest), dest + dir)
	if list_of_multi_hops.is_empty():
		return ret_val
	for journey : Array in list_of_multi_hops:
		ret_val.append(CAction.create_attack(checker, journey, self))
	return ret_val

func get_multi_hops(checker : Checker, foe : Checker, hop_loc : Vector2i) -> Array[Array]:
	# hop_loc guarenteed to have jumped over foe
	var ret_val : Array[Array]
	var hop_contents : SquareContents = get_contents(hop_loc, checker.side)
	if hop_contents != SquareContents.empty:
		return ret_val
	var extention_hops : Array[Array]
	var right_dir : Vector2i = Vector2i(1, checker.move_dir)
	var right_contents : SquareContents = get_contents(hop_loc + right_dir, checker.side)
	if right_contents == SquareContents.enemy:
		var right_multi_hops : Array[Array] = get_multi_hops(checker, get_checker(hop_loc + right_dir), hop_loc + right_dir + right_dir)
		extention_hops.append_array(right_multi_hops)
	var left_dir : Vector2i = Vector2i(-1, checker.move_dir)
	var left_contents : SquareContents = get_contents(hop_loc + left_dir, checker.side)
	if left_contents == SquareContents.enemy:
		var left_multi_hops : Array[Array] = get_multi_hops(checker, get_checker(hop_loc + left_dir), hop_loc + left_dir + left_dir)
		extention_hops.append_array(left_multi_hops)
	var hop : Array = [foe, hop_loc]
	if extention_hops.is_empty():
		var journey : Array[Array] = [hop]
		ret_val.append(journey)
	else:
		for journey : Array in extention_hops:
			var total_journey : Array[Array]
			total_journey.append(hop)
			total_journey.append_array(journey)
			ret_val.append(total_journey)
	return ret_val
		
func get_moves() -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	for checker : Checker in pieces:
		if checker.alive == false:
			continue
		if (checker.side == 2) == human_turn:
			if checker.move_dir != 1:
				ret_val.append_array(get_moves_in_direction(checker, Vector2i(-1, -1)))
				ret_val.append_array(get_moves_in_direction(checker, Vector2i(1, -1)))
			if checker.move_dir != -1:
				ret_val.append_array(get_moves_in_direction(checker, Vector2i(-1, 1)))
				ret_val.append_array(get_moves_in_direction(checker, Vector2i(1, 1)))
	return ret_val

func get_score() -> MMCScore:
	return CScore.create(self)
