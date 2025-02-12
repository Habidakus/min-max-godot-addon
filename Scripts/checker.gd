class_name Checker extends Node2D

var alive : bool = true
var square : Vector2i
var move_dir : int = 0
var side : int = 0
var poly : Polygon2D
var pending_hops : Array[Vector2i]

const SPEED : float = 550.0

func clone() -> Checker:
	var ret_val : Checker = Checker.new()
	ret_val.alive = alive
	ret_val.square = square
	ret_val.move_dir = move_dir
	ret_val.side = side
	ret_val.poly = poly
	return ret_val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	poly = find_child("Polygon2D") as Polygon2D

func init(x : int, y : int, dir : int, player : int) -> void:
	alive = true
	show()
	square = Vector2i(x, y)
	move_dir = dir
	side = player
	set_default_color()

func set_default_color() -> void:
	if side == 1:
		poly.color = Color.BLACK
	else:
		poly.color = Color.ANTIQUE_WHITE

func highlight(color : Color) -> void:
	poly.color = color

func kill() -> void:
	alive = false
	square = Vector2i(-1, -1)
	pending_hops.clear()
	self.hide()

func handle_pending_hops() -> bool:
	if pending_hops.is_empty():
		return false
	square = pending_hops[0]
	pending_hops.remove_at(0)
	return true

func move(board : GridContainer, delta : float) -> bool:
	if alive == false:
		return false

	var travel_dist : float = SPEED * delta
	for child in board.get_children():
		if child is ColorRect:
			var board_square : ColorRect = child as ColorRect
			var board_square_loc : Vector2i = board_square.get_meta("loc") as Vector2i
			if board_square_loc == square:
				var center : Vector2 = board_square.global_position + board_square.size / 2
				if global_position == center:
					return handle_pending_hops()
				var vector_to : Vector2 = center - global_position
				var dist_squared = vector_to.length_squared()
				if dist_squared < travel_dist * travel_dist:
					global_position = center
					return handle_pending_hops()
				global_position = global_position + vector_to.normalized() * travel_dist
				return true
	assert(false)
	return false
