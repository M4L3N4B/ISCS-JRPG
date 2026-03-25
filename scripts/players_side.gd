extends Node2D
var players: Array = []
var combat_queue: Array = []
var is_battle_playing: bool = false
var indexSelect: int = 0

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
	
func _on_player_died(player):
	players.erase(player)
	if indexSelect >= players.size():
		indexSelect = players.size() - 1
	
	if players.size() > 0:
		players[indexSelect].focus()

func _on_enemies_next_player() -> void:
	if indexSelect < players.size() - 1:
			indexSelect += 1
			switch_focus(indexSelect, indexSelect-1)
	else:
		indexSelect = 0
		switch_focus(indexSelect, players.size()-1)

# Source: https://www.youtube.com/watch?v=HEexLmt7enc
