extends CharacterBody2D

@onready var _focus = $Selected
@onready var animation = get_node_or_null("AnimatedSprite2D")
@onready var health_bar = $HealthBar

@export var character_name: String = ""
@export var MAX_HEALTH: float = 100
signal died(character)

@export var attacks: Array[Attack] = []
@export var attack_animations: Array[String] = []

# Gameplay loop variables
var attack_charged: Attack = null
var is_charging: bool = false
var is_defending: bool = false

var current_health = MAX_HEALTH:
	set(value):
		current_health = value
		_update_progress_bar()
		
		if current_health > 0:
			animation.play("hit")
			await animation.animation_finished
			animation.play("idle")
		
		else:
			animation.play("death")
			await animation.animation_finished
			emit_signal("died", self)
			queue_free()


func _ready():
	if animation:
		animation.play("idle")


func receive_damage(value):
	# Halve the damage taken if defending
	if is_defending:
		value *= 0.5
		is_defending = false

	current_health -= value


func use_attack(attack: Attack, target: CharacterBody2D):
	# Don't allow the attack if charged
	if attack.charged and not is_charging:
		is_charging = true
		attack_charged = attack
		return
	
	# Allow next move to be performed
	is_charging = false
	attack_charged = null
	
	# Calculate crit
	var end_damage = attack.damage
	if randf() < attack.crit_chance:
		end_damage *= 1.5
		print("Critical hit")
	
	await play_attack_animation(attack)
	
	# Have opponent take damage
	target.receive_damage(end_damage)
	
	if animation:
		animation.play("idle")
	

# is_defending is applied in receive_damage
func defend():
	is_defending = true


func play_attack_animation(attack: Attack):
	if animation:
		var idx = attacks.find(attack)
		if idx < 0 or idx >= attack_animations.size():
			return

		animation.play( attack_animations[idx] )
		await animation.animation_finished
		animation.play("idle")


# UI Functions
func _update_progress_bar():
	health_bar.value = current_health

func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()
