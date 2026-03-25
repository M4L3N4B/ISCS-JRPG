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

func _process(delta):
	if not playerChoice.visible:
		if Input.is_action_just_pressed("Select Up"):
			if indexSelect > 0:
				indexSelect -= 1
				switch_focus(indexSelect, indexSelect+1)
				
		if Input.is_action_just_pressed("Select Down"):
			if indexSelect < enemies.size() - 1:
				indexSelect += 1
				switch_focus(indexSelect, indexSelect-1)
				
		if Input.is_action_just_pressed("Select Action"):
			if playersSide.attack_chosen == null:
				return
		
			combat_queue.push_back({"action": "attack", "target": indexSelect, "attack": playersSide.attack_chosen})
			emit_signal("next_player")
		
	if combat_queue.size() == playersSide.players.size() and not is_battle_playing:
		is_battle_playing = true
		_play_action(combat_queue)
		
		
func _play_action(stack):
	for move in stack:
		if move.action == "defend":
			continue
		if move.action == "attack":
			enemies[move.target].receive_damage(move.attack.damage)
			await get_tree().create_timer(1).timeout
	
	combat_queue.clear()
	is_battle_playing = false
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

func _reset_focus():
	indexSelect = 0
	for enemy in enemies:
		enemy.unfocus()
		
func _focus_choosing():
	_reset_focus()
	enemies[0].focus()

func _on_attack_pressed() -> void:
	playerChoice.hide()
	playersSide._show_attack_choices() # Show when attack button pressed
	_focus_choosing()

func _on_defend_pressed() -> void:
	playerChoice.hide()
	combat_queue.push_back({"action": "defend"}) # Push that no one is targeted
	emit_signal("next_player")

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
