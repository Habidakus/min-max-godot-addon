extends StateMachineState

@export var next_state : StateMachineState
@export var time_out_in_seconds : float = -1

@export var fade_in : bool = false
@export var fade_out : bool = false
@export var fade_time : float = 1.5

var countdown : float = 0
var leave_tween : Tween = null

func _process(delta: float) -> void:
	if time_out_in_seconds > 0:
		countdown += delta
		if countdown > time_out_in_seconds:
			our_state_machine.switch_state_internal(next_state)

func _input(event : InputEvent) -> void:
	handle_event(event)

func _unhandled_input(event : InputEvent) -> void:
	handle_event(event)

func handle_event(event : InputEvent) -> void:
	# We process on "released" instead of pressed because otherwise immediately
	# switching screens could still have the mouse being pressed on some other
	# screen's button.
	if leave_tween == null:
		if event.is_released():
			if event is InputEventKey:
				our_state_machine.switch_state_internal(next_state)
			if event is InputEventMouseButton:
				our_state_machine.switch_state_internal(next_state)

func exit_state(next_state: StateMachineState, callback : Callable) -> void:
	if !fade_out:
		super.exit_state(next_state, callback)
		return
	
	if leave_tween != null && leave_tween.is_running():
		return

	leave_tween = get_tree().create_tween()
	self.modulate = Color(Color.WHITE, 1)
	var destination_color : Color = Color(Color.WHITE, 0)
	leave_tween.tween_property(self, "modulate", destination_color, fade_time)
	#for child in get_children():
		#if child is CanvasLayer:
			#child.scale = Vector2(1, 1)
			#leave_tween.parallel()
			#leave_tween.tween_property(child, "scale", Vector2(0.01, 0.01), fade_time)
	var when_finished_callback : Callable = Callable(self, "on_leave_tween_finished")
	when_finished_callback.bind(callback)
	leave_tween.tween_callback(when_finished_callback)

func on_leave_tween_finished(finish_callback : Callable) -> void:
	leave_tween = null
	finish_callback.call()

func enter_state() -> void:
	countdown = 0
	leave_tween = null
	super.enter_state()
	if fade_in:
		self.modulate = Color(Color.WHITE, 0)
		var tween : Tween = get_tree().create_tween()
		var destination_color : Color = Color(Color.WHITE, 1)
		tween.tween_property(self, "modulate", destination_color, fade_time)
		#for child in get_children():
			#if child is CanvasLayer:
				#child.scale = Vector2(0.01, 0.01)
				#tween.parallel()
				#tween.tween_property(child, "scale", Vector2(1,1), fade_time)
	
