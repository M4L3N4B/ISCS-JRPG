extends CharacterBody2D

@onready var _focus = $Selected
@onready var animation = get_node_or_null("AnimatedSprite2D")
@onready var health_bar = $HealthBar

@export var MAX_HEALTH: float = 100

signal died(character)

var current_health = MAX_HEALTH:
	set(value):
		current_health = value
		_update_progress_bar()
		
		if current_health > 0:
			animation.play("hit")
		
		else:
			animation.play("death")
			await animation.animation_finished
			emit_signal("died", self)
			queue_free()

func receive_damage(value):
	current_health -= value

# UI Functions
func _update_progress_bar():
	health_bar.value = current_health

func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()
