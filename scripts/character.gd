extends CharacterBody2D

@onready var _focus = $Selected
@onready var animation = get_node_or_null("AnimatedSprite2D")
@onready var health_bar = $HealthBar

@export var MAX_HEALTH: float = 100

var current_health = MAX_HEALTH:
	set(value):
		current_health = value
		_update_progress_bar()
		_play_animation()
		
func _update_progress_bar():
	health_bar.value = current_health
	
func _play_animation():
	animation.play("hit")

func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()
