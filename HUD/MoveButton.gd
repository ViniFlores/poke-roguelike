extends Button

signal move_focused(move)

var move : 
	set(val):
		move = val
		text = move.name.replace("-", " ").to_upper()

func _ready():
	pressed.connect(execute_move)
	focus_entered.connect(focus_move)
	mouse_entered.connect(focus_move)

func execute_move():
	if not move:
		return
	Global.battle_round(move)

func focus_move():
	move_focused.emit(move)
