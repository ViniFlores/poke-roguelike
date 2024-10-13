extends HBoxContainer

var moves = []
@onready var moves_container = $MovesPanel/MarginContainer/MovesContainer
@onready var pp_value = $InfoContainer/MarginContainer/VBoxContainer/HBoxContainer/PPValue
@onready var type_value = $InfoContainer/MarginContainer/VBoxContainer/HBoxContainer2/TypeValue

func _ready():
	if Global.player_pokemon:
		update_moves(Global.player_pokemon)
	Global.changed_player_pokemon.connect(update_moves)
	
	visibility_changed.connect(func (): if(visible): moves_container.get_child(0).grab_focus())
	
	for move_button in moves_container.get_children():
		move_button.move_focused.connect(
			func(m):
				if not m:
					return
				pp_value.text = "%s/%s" % [str(m.pp), str(m.pp)]
				type_value.text = m.type.name.to_upper()
		)

func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		Global.hud.select_menu(Global.hud.main_menu)

func update_moves(pkmn):
	moves = pkmn.moves
	for i in len(moves):
		var node = moves_container.get_child(i - 1)
		node.move = moves[i]
