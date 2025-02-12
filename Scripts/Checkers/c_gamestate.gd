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
			if !clone.is_king():
				if clone.square.y == 0 && clone.side == 2:
					clone.king()
				elif clone.square.y == board_size - 1 && clone.side == 1:
					clone.king()
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
	var already_cleared_foes : Array[Checker]
	var list_of_multi_hops : Array[Array] = get_multi_hops(checker, get_checker(dest), dest + dir, already_cleared_foes)
	if list_of_multi_hops.is_empty():
		return ret_val
	for journey : Array in list_of_multi_hops:
		ret_val.append(CAction.create_attack(checker, journey, self))
	return ret_val

func get_multi_hops(checker : Checker, foe : Checker, hop_loc : Vector2i, already_jumped_foes : Array[Checker]) -> Array[Array]:
	# hop_loc guarenteed to have jumped over foe
	var ret_val : Array[Array]
	var hop_contents : SquareContents = get_contents(hop_loc, checker.side)
	if hop_contents != SquareContents.empty:
		return ret_val
	var extention_hops : Array[Array]
	var multi_hops : Array[Array]
	var already_cleared_foes : Array[Checker]
	already_cleared_foes.append_array(already_jumped_foes)
	already_cleared_foes.append(foe)
	if checker.is_king():
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(1, 1), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(-1, 1), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(1, -1), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(-1, -1), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
	else:
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(1, checker.move_dir), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
		multi_hops = get_multi_hops_from_direction(checker, hop_loc, Vector2i(-1, checker.move_dir), already_cleared_foes)
		if multi_hops != null && !multi_hops.is_empty():
			extention_hops.append_array(multi_hops)
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

func get_multi_hops_from_direction(checker : Checker, hop_loc : Vector2i, dir : Vector2i, already_jumped_foes : Array[Checker]) -> Array[Array]:
	var right_contents : SquareContents = get_contents(hop_loc + dir, checker.side)
	if right_contents == SquareContents.enemy:
		var foe : Checker = get_checker(hop_loc + dir)
		if !already_jumped_foes.has(foe):
			return get_multi_hops(checker, foe, hop_loc + dir + dir, already_jumped_foes)
	var empty : Array[Array]
	return empty
			
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
