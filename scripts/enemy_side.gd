extends Node2D

func flip_sprites():
	var sprites = find_children("*", "Sprite2D", true, false)
	sprites += find_children("*", "AnimatedSprite2D", true, false)
	for s in sprites:
		s.flip_h = true

func _ready():
	flip_sprites()
