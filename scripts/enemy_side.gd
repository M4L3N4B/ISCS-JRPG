extends Node2D
var enemies: Array = []
var combat_queue: Array = []
var is_battle_playing: bool = false
var indexSelect: int = 0

@onready var playerChoice = $"../CanvasLayer/PlayerChoice"
@onready var playersSide = $"../Players"

signal next_player

func flip_sprites():
	for enemy in enemies:
		for child in enemy.get_children():
			if child is Sprite2D or child is AnimatedSprite2D:
				child.flip_h = true

func _ready():
	enemies = get_children()
	for enemy in enemies:
		enemy.connect("died", Callable(self, "_on_enemy_died"))
	flip_sprites()
	enemies[1].unfocus()
	show_player_choices()


# Handles keypresses
func _process(_delta):
	if is_battle_playing:
		return
		
	if not playerChoice.visible:
		# Don't allow enemy focus to move when players are still choosing
		if playersSide.playerChoice.visible or playersSide.attackChoice.visible:
			return
	
		if Input.is_action_just_pressed("Select Up"):
			if indexSelect > 0:
				indexSelect -= 1
				switch_focus(indexSelect, indexSelect+1)
				
		if Input.is_action_just_pressed("Select Down"):
			if indexSelect < enemies.size() - 1:
				indexSelect += 1
				switch_focus(indexSelect, indexSelect-1)
				
		if Input.is_action_just_pressed("Select Action"):
			if playersSide.attack_chosen == null or playersSide.attackChoice.visible:
				return
		
			combat_queue.push_back({
				"action": "attack",
				"target": indexSelect,
				"attack": playersSide.attack_chosen,
				"attacker": playersSide.players[playersSide.indexSelect]
			})
			
			playersSide.attack_chosen = null
			emit_signal("next_player")
		
	if combat_queue.size() == playersSide.players.size() and not is_battle_playing:
		is_battle_playing = true
		_play_action(combat_queue)
		
		
func _play_action(stack):
	# Remove all acting players; for the next round
	playersSide.players_done.clear()

	for move in stack:
		if move.action == "defend":
			continue
		if move.action == "attack":
			if enemies.size() > 0 and move.target < enemies.size():
				await move.attacker.use_attack(move.attack, enemies[move.target])
			await get_tree().create_timer(1).timeout
			
	_enemy_turn()
	combat_queue.clear()
	is_battle_playing = false
	playersSide.reset_turn()
	show_player_choices()
			
func switch_focus(x, y):
	enemies[x].focus()
	enemies[y].unfocus()
	
func _on_enemy_died(enemy):
	enemies.erase(enemy)
	if indexSelect >= enemies.size():
		indexSelect = enemies.size() - 1
	
	if enemies.size() > 0:
		enemies[indexSelect].focus()

func show_player_choices():
	playerChoice.show()
	playerChoice.find_child("Attack").grab_focus()
	_reset_focus()

func _reset_focus():
	indexSelect = 0
	for enemy in enemies:
		enemy.unfocus()
		
func _focus_choosing():
	_reset_focus()
	enemies[0].focus()


func _on_attack_pressed() -> void:
	playerChoice.hide()
	playersSide._show_attack_choices() # Show list of attacks when attack button pressed


func _on_defend_pressed() -> void:
	playerChoice.hide()
	combat_queue.push_back({"action": "defend"}) # Push that no one is targeted
	emit_signal("next_player")

func _enemy_turn():
	for enemy in enemies:
		if enemy.current_health <= 0:
			continue
			
		if randf() < 0.15:
			enemy.defend()
			print(enemy.character_name + " is defending (TEST).")
			
		else:
			if playersSide.players.size() > 0:
				var targetPlayer = playersSide.players[randi() % playersSide.players.size()]
				var attack = enemy.attacks[0]
				await enemy.use_attack(attack, targetPlayer)
				if enemy.is_charging:
					print(enemy.character_name + " is supposed to attack " + targetPlayer.character_name + " (TEST), but is charging.")
				else:
					print(enemy.character_name + " attacks " + targetPlayer.character_name + " (TEST).")
				
		await get_tree().create_timer(1).timeout

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
