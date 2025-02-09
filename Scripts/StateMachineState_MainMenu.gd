extends StateMachineState

func _on_tic_tac_toe_button_up() -> void:
	our_state_machine.switch_state("State_TicTacToe")

func _on_dalmudi_button_up() -> void:
	our_state_machine.switch_state("State_Dalmudi")

func _on_checkers_button_up() -> void:
	our_state_machine.switch_state("State_Checkers")
