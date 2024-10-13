extends Control

var battle_scene = preload("res://battle.tscn")

func _on_button_pressed():
	var battle = battle_scene.instantiate()
	battle.get_node("PlayerPokemon").pokemon_id = str(floor($CenterContainer/VBoxContainer/SpinBox.value))
	get_tree().root.add_child(battle)
	queue_free()
