extends Node2D

class_name Pokemon

enum Team {
	Player, Enemy
}

@export var pokemon_id: String = '150'
@export var team: Team = Team.Player

signal loaded

var base_exp = 0

var min_exp = 0 :
	set(val):
		min_exp = val
		if team == Team.Player:
			$XPBar.min_value = min_exp
var target_exp = 0 :
	set(val):
		target_exp = val
		if team == Team.Player:
			$XPBar.max_value = target_exp
var exp = 0 :
	set(val):
		exp = val
		if team == Team.Player:
			$XPBar.value = exp
			if exp >= target_exp:
				level += 1
				update_stats()

var species
var types = []

var pokemon_name: String = "Sem nome" : 
	set(val):
		pokemon_name = val
		$Name.text = val

var hp :
	set(val):
		hp = max(0, val)
		$HPBar.max_value = int(stats.hp)
		$HPBar.value = int(hp)
		if team == Team.Player:
			$Hp.text = str(hp) + '/' + str(stats.hp)

var level = 10 :
	set(val):
		level = val
		$Level.text = "Lv " + str(level)
		target_exp = (level + 1)**3 * (100 - level + 1)/100
		min_exp = (level)**3 * (100 - level)/100

var stats = {
	'hp': 0,
	'attack': 0,
	'defense': 0,
	'special-attack': 0,
	'special-defense': 0,
	'speed': 0
}

var base_stats = {
	'hp': 0,
	'attack': 0,
	'defense': 0,
	'special-attack': 0,
	'special-defense': 0,
	'speed': 0
}

var moves = []

func _ready():
	if team == Team.Enemy:
		pokemon_id = str(randi_range(1, 350))
	$FetchPokemonDataHTTP.request("https://pokeapi.co/api/v2/pokemon/" + pokemon_id)

func _on_fetch_pokemon_data_http_request_completed(result, response_code, headers, body):
	assert(response_code == 200, "PokeAPI request failed.")
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	pokemon_name = json.name.to_upper()
	base_exp = json.base_experience
	update_pokemon_sprite(json.sprites.back_default if team == Team.Player else json.sprites.front_default)
	base_stats = json.stats
	types = json.types
	$Level.text = "Lv " + str(level)
	target_exp = (level + 1)**3 * (100 - level + 1)/100
	exp = level**3 * (100 - level)/100
	min_exp = exp
	update_stats()
	await generate_moves(json.moves)
	
	if team == Team.Enemy:
		Global.enemy_pokemon = self
	if team == Team.Player:
		Global.player_pokemon = self
	
	loaded.emit()

func update_pokemon_sprite(url: String):
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", 
		func(result, response_code, headers, body):
			remove_child(http_request)
			var img = Image.new()
			var err = img.load_png_from_buffer(body)
			assert(err == OK, "Image download failed.")
			var img_texture: ImageTexture = ImageTexture.create_from_image(img)
			$Sprite2D.texture = img_texture
			)
	http_request.request(url)

func update_stats():
	var temp_iv = 15
	var temp_ev = 100
	for entry in base_stats:
		if entry.stat.name == 'hp':
			stats[entry.stat.name] = floor(((entry.base_stat * 2 + temp_iv + temp_ev/4) * level / 100) + level + 10)
			hp = stats.hp
		else: 
			stats[entry.stat.name] = floor(((entry.base_stat * 2 + temp_iv + temp_ev/4) * level / 100) + 5)

var latest_api_move
func generate_moves(move_list):
	var possible_moves = move_list.filter(
		func(move):
			return move.version_group_details[0].level_learned_at <= level and move.version_group_details[0].move_learn_method.name == "level-up"
	)
	
	var http = HTTPRequest.new()
	http.request_completed.connect(
		func(result, response_code, headers, body):
			latest_api_move = JSON.parse_string(body.get_string_from_utf8())
	)
	add_child(http)
	
	for i in min(4, len(possible_moves)):
		var attempts = 0
		while (true):
			attempts += 1
			http.request(possible_moves[randi_range(0, len(possible_moves) - 1)].move.url)
			await http.request_completed
			if latest_api_move.power:
				moves.append(latest_api_move)
				break
			if attempts > 3:
				break
	
	remove_child(http)
	return

func update_species(species):
	var http = HTTPRequest.new()
	http.request_completed.connect(
		func(result, response_code, headers, body):
			species = JSON.parse_string(body.get_string_from_utf8())
	)
	add_child(http)
	http.request(species.url)
	await http.request_completed
	remove_child(http)
	
