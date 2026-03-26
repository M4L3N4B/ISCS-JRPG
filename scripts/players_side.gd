extends Node2D
var players: Array = []
var combat_queue: Array = []
var is_battle_playing: bool = false
var indexSelect: int = 0
var players_done: Array = []

@onready var playerChoice = $"../CanvasLayer/PlayerChoice"
@onready var attackChoice = $"../CanvasLayer/AttackChoice"
@onready var enemySide = get_node("../Enemies")
var attack_chosen: Attack = null

func _ready():
	players = get_children()
	for player in players:
		player.connect("died", Callable(self, "_on_player_died"))
	players[0].focus()
	players[1].unfocus()

func _process(_delta):
	# Go back to previous menu
	if attackChoice.visible:
		if Input.is_action_just_pressed("ui_text_backspace"):
			attackChoice.hide()
			playerChoice.show()
			playerChoice.get_child(0).grab_focus()
			return
	
	# Don't allow player focus to move when choosing attack or target
	if not playerChoice.visible:
		return
	
	if Input.is_action_just_pressed("Select Up"):
		move_to_valid_focus(-1)
			
	if Input.is_action_just_pressed("Select Down"):
		move_to_valid_focus(1)


# Select only players that haven't chosen a move yet
func move_to_valid_focus(direction: int):
	var index_to_check = indexSelect + direction
	while 0 <= index_to_check and index_to_check < players.size():
		if not players_done.has( players[index_to_check] ):
			switch_focus(index_to_check, indexSelect)
			indexSelect = index_to_check
			break
		index_to_check += direction


func switch_focus(x, y):
	players[x].focus()
	players[y].unfocus()


# Show the submenu of a player character's attacks
func _show_attack_choices():
	var player = players[indexSelect]
	
	# Remove previous attacks from attackChoice
	for child in attackChoice.get_children():
		child.free()
	
	# Fill attackChoice with buttons for selected character's attacks
	for attack in player.attacks:
		var btn = Button.new()
		btn.text  = attack.name
		btn.pressed.connect( _on_attack_selected.bind(attack) )
		attackChoice.add_child(btn)
	
	attackChoice.show()
	playerChoice.find_child("Attack").release_focus()
	attackChoice.get_child(0).grab_focus() # Automatically select first option


func _on_attack_selected(attack: Attack):
	attackChoice.hide()
	attack_chosen = attack
	enemySide._focus_choosing() # Only show enemy focus when an attack has been selected


func _on_player_died(player):
	players.erase(player)
	if indexSelect >= players.size():
		indexSelect = players.size() - 1
	
	if players.size() > 0:
		players[indexSelect].focus()


# Go to next character
func _on_enemies_next_player() -> void:
	players_done.append(players[indexSelect])
	
	if players_done.size() == players.size():
		return
	
	_move_to_unacted_player()
	enemySide.show_player_choices()
	

func _move_to_unacted_player():
	# Find first player that hasn't chosen a move yet
	for i in range( players.size() ):
		indexSelect = (indexSelect + 1) % players.size()
		if not players_done.has( players[indexSelect] ):
			break
	
	# Focus only on selected player
	for player in players:
		if players_done.has(player):
			player.unfocus()
	players[indexSelect].focus()

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
