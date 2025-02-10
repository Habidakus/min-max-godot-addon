class_name Card extends Node2D

var rank : int = 0
var sort_order : float = 0
var player : int = -1
var tween : Tween = null

func _to_string() -> String:
	return ("Rank=" + str(rank) + ", Player=" + str(player) + ", X=" + str(int(global_position.x)) + ", Y=" + str(int(global_position.y)))

func set_rank(r : int) -> void:
	rank = r
	(find_child("Label") as Label).text = str(rank)

func stopped_moving() -> void:
	tween = null

func matches_rank_and_player(r : int, p : int) -> bool:
	return rank == r && player == p

func matches_card(other : Card) -> bool:
	return rank == other.rank && player == other.player

func matches_hand(p : int) -> bool:
	return player == p

func discard(pos : Vector2) -> void:
	player = 0
	tween = create_tween()
	tween.tween_property(self, "global_position", pos, 1)
	tween.tween_callback(Callable(self, "stopped_moving"))

func set_pending_pos(pos : Vector2) -> bool:
	if pos == global_position:
		return false
	if tween != null:
		return true
	
	tween = create_tween()
	tween.tween_property(self, "global_position", pos, 1)
	tween.tween_callback(Callable(self, "stopped_moving"))
	return true
