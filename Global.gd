extends Node

signal changed_player_pokemon(pkmn: Pokemon)
signal changed_enemy_pokemon(pkmn: Pokemon)

var enemy_pokemon_scene = preload("res://enemy_pokemon.tscn")
var main_menu_scene = preload("res://main_menu.tscn")

var stab_table = {
  "normal": {
	"rock": 0.5,
	"ghost": 0,
	"steel": 0.5
  },
  "fire": {
	"fire": 0.5,
	"water": 0.5,
	"grass": 2,
	"ice": 2,
	"bug": 2,
	"rock": 0.5,
	"dragon": 0.5,
	"steel": 2
  },
  "water": {
	"fire": 2,
	"water": 0.5,
	"grass": 0.5,
	"ground": 2,
	"rock": 2,
	"dragon": 0.5
  },
  "electric": {
	"water": 2,
	"electric": 0.5,
	"grass": 0.5,
	"ground": 0,
	"flying": 2,
	"dragon": 0.5
  },
  "grass": {
	"fire": 0.5,
	"water": 2,
	"grass": 0.5,
	"poison": 0.5,
	"ground": 2,
	"flying": 0.5,
	"bug": 0.5,
	"rock": 2,
	"dragon": 0.5,
	"steel": 0.5
  },
  "ice": {
	"fire": 0.5,
	"water": 0.5,
	"grass": 2,
	"ice": 0.5,
	"ground": 2,
	"flying": 2,
	"dragon": 2,
	"steel": 0.5
  },
  "fighting": {
	"normal": 2,
	"ice": 2,
	"poison": 0.5,
	"flying": 0.5,
	"psychic": 0.5,
	"bug": 0.5,
	"rock": 2,
	"ghost": 0,
	"dark": 2,
	"steel": 2,
	"fairy": 0.5
  },
  "poison": {
	"grass": 2,
	"poison": 0.5,
	"ground": 0.5,
	"rock": 0.5,
	"ghost": 0.5,
	"steel": 0,
	"fairy": 2
  },
  "ground": {
	"fire": 2,
	"electric": 2,
	"grass": 0.5,
	"poison": 2,
	"flying": 0,
	"bug": 0.5,
	"rock": 2,
	"steel": 2
  },
  "flying": {
	"electric": 0.5,
	"grass": 2,
	"fighting": 2,
	"bug": 2,
	"rock": 0.5,
	"steel": 0.5
  },
  "psychic": {
	"fighting": 2,
	"poison": 2,
	"psychic": 0.5,
	"dark": 2,
	"steel": 0.5
  },
  "bug": {
	"fire": 0.5,
	"grass": 2,
	"fighting": 0.5,
	"poison": 0.5,
	"flying": 0.5,
	"psychic": 2,
	"ghost": 0.5,
	"dark": 2,
	"steel": 0.5,
	"fairy": 0.5
  },
  "rock": {
	"fire": 2,
	"ice": 2,
	"fighting": 0.5,
	"ground": 0.5,
	"flying": 0.5,
	"bug": 2,
	"steel": 0.5
  },
  "ghost": {
	"normal": 0,
	"psychic": 2,
	"ghost": 2,
	"dark": 0.5
  },
  "dragon": {
	"dragon": 2,
	"steel": 0.5,
	"fairy": 0
  },
  "dark": {
	"fighting": 0.5,
	"psychic": 2,
	"ghost": 2,
	"dark": 0.5,
	"fairy": 0.5
  },
  "steel": {
	"fire": 0.5,
	"water": 0.5,
	"electric": 0.5,
	"ice": 2,
	"rock": 2,
	"steel": 0.5,
	"fairy": 2
  },
  "fairy": {
	"fire": 0.5,
	"fighting": 2,
	"poison": 0.5,
	"dragon": 2,
	"dark": 2,
	"steel": 0.5
  }
}


var hud: HUD

var player_pokemon: Pokemon :
	set(val):
		player_pokemon = val
		emit_signal("changed_player_pokemon", val)
		player_pokemon.loaded.connect(on_loaded)

var enemy_pokemon: Pokemon:
	set(val):
		enemy_pokemon = val
		emit_signal("changed_enemy_pokemon", val)
		enemy_pokemon.loaded.connect(on_loaded)

func on_loaded():
	if enemy_pokemon and player_pokemon:
		hud.select_menu(hud.main_menu)

func execute_player_move(move):
	await hud.show_message("%s usou \n%s" % [player_pokemon.pokemon_name, move.name.replace("-", " ").to_upper()])
	var calc = damage_calculation(player_pokemon, enemy_pokemon, move)
	enemy_pokemon.hp = enemy_pokemon.hp - calc[0]
	if calc[1] > 1:
		await hud.show_message("Foi muito efetivo!")
	if calc[1] < 1:
		await hud.show_message("Nao foi efetivo!")

func damage_calculation(source_pkmn, dest_pkmn, move):
	if not move.power:
		return 0
	var power_stat = 'attack' if move.damage_class.name == "physical" else 'special-attack'
	var def_stat = 'defense' if move.damage_class.name == "physical" else 'special-defense'
	
	var random = randf_range(0.85, 1.0)
	var stab = 1
	for type in dest_pkmn.types:
		if stab_table[move.type.name].has(type.type.name):
			stab *= stab_table[move.type.name][type.type.name]
		
	
	var result = (floor((((2*source_pkmn.level/5 + 2) * move.power * source_pkmn.stats[power_stat]/dest_pkmn.stats[def_stat])/50 + 2) * random * stab))
	
	return [result, stab]

func execute_random_enemy_move():
	if (len(enemy_pokemon.moves) == 0):
		await hud.show_message("%s nao sabe o que fazer." % enemy_pokemon.pokemon_name)
		return
	var move = enemy_pokemon.moves[randi_range(0, len(enemy_pokemon.moves) - 1)]
	await hud.show_message("%s usou \n%s" % [enemy_pokemon.pokemon_name, move.name.replace("-", " ").to_upper()])
	var calc = damage_calculation(enemy_pokemon, player_pokemon, move)
	player_pokemon.hp = player_pokemon.hp - calc[0]
	if calc[1] > 1:
		await hud.show_message("Foi muito efetivo!")
	if calc[1] < 1:
		await hud.show_message("Nao foi efetivo!")

func back_to_main_menu():
	var menu = main_menu_scene.instantiate()
	var current_scene = get_tree().root.get_child(-1)
	get_tree().root.add_child(menu)
	current_scene.queue_free()

func battle_round(move):
	if player_pokemon.stats.speed > enemy_pokemon.stats.speed:
		await execute_player_move(move)
		if enemy_pokemon.hp > 0:
			await execute_random_enemy_move()
			if player_pokemon.hp <= 0:
				back_to_main_menu()
	elif player_pokemon.stats.speed <= enemy_pokemon.stats.speed:
		await execute_random_enemy_move()
		if player_pokemon.hp <= 0:
			back_to_main_menu()
		await execute_player_move(move)
	
	if enemy_pokemon.hp == 0:
		spawn_new_enemy()
	else:
		hud.select_menu(hud.fight_menu)

func spawn_new_enemy():
	var fainted_enemy_name = enemy_pokemon.pokemon_name
	var pos = enemy_pokemon.global_position
	var gained_exp = floor(enemy_pokemon.base_exp * enemy_pokemon.level / 7)
	enemy_pokemon.queue_free()
	await hud.show_message("%s foi derrotado." % fainted_enemy_name)
	var level_up = player_pokemon.target_exp <= player_pokemon.exp + gained_exp
	player_pokemon.exp += gained_exp
	await hud.show_message("%s recebeu %s pontos de experiencia." % [player_pokemon.pokemon_name, str(gained_exp)])
	if level_up:
		await hud.show_message("%s ganhou um level e recuperou seu HP." % player_pokemon.pokemon_name)
	var new_enemy = enemy_pokemon_scene.instantiate()
	new_enemy.level = randi_range(floor(player_pokemon.level / 2),player_pokemon.level)
	new_enemy.global_position = pos
	get_tree().root.get_child(-1).add_child(new_enemy)
	await new_enemy.loaded
	
	hud.select_menu(hud.fight_menu)
