extends Node2D
var players: Array = []
var combat_queue: Array = []
var is_battle_playing: bool = false
var indexSelect: int = 0

@onready var attackChoice = $"../CanvasLayer/AttackChoice"
@onready var enemySide = get_node("../Enemies")
var attack_chosen: Attack = null

func _ready():
	players = get_children()
	for player in players:
		player.connect("died", Callable(self, "_on_player_died"))
	players[0].focus()
	players[1].unfocus()

func _process(delta):
	if Input.is_action_just_pressed("Select Up"):
		if indexSelect > 0:
			indexSelect -= 1
			switch_focus(indexSelect, indexSelect+1)
			
	if Input.is_action_just_pressed("Select Down"):
		if indexSelect < players.size() - 1:
			indexSelect += 1
			switch_focus(indexSelect, indexSelect-1)
			
func switch_focus(x, y):
	players[x].focus()
	players[y].unfocus()


# Show the submenu of a player character's attacks
func _show_attack_choices():
	var player = players[indexSelect]
	
	# Remove previous attacks from attackChoice
	for child in attackChoice.get_children():
		child.queue_free()
	
	# Fill attackChoice with buttons for selected character's attacks
	for attack in player.attacks:
		var btn = Button.new()
		btn.text = attack.name
		btn.pressed.connect( _on_attack_selected.bind(attack) )
		attackChoice.add_child(btn)
	
	attackChoice.show()
	attackChoice.get_child(0).grab_focus() # Automatically select first option


func _on_attack_selected(attack: Attack):
	attackChoice.hide()
	attack_chosen = attack


func _on_player_died(player):
	players.erase(player)
	if indexSelect >= players.size():
		indexSelect = players.size() - 1
	
	if players.size() > 0:
		players[indexSelect].focus()

func _on_enemies_next_player() -> void:
	if combat_queue.size() == players.size():
		return

	if indexSelect < players.size() - 1:
			indexSelect += 1
			switch_focus(indexSelect, indexSelect-1)
	else:
		indexSelect = 0
		switch_focus(indexSelect, players.size()-1)

	enemySide.show_player_choices()

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
