extends Node2D
var enemies: Array = []
var combat_queue: Array = []
var is_battle_playing: bool = false
var indexSelect: int = 0

@onready var playerChoice = $"../CanvasLayer/PlayerChoice"

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
			combat_queue.push_back(indexSelect)
			emit_signal("next_player")
		
	if combat_queue.size() == enemies.size() and not is_battle_playing:
		is_battle_playing = true
		_play_action(combat_queue)
		
func _play_action(stack):
	for indexCombat in stack:
		enemies[indexCombat].receive_damage(15)
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
	_focus_choosing()

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
