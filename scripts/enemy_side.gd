extends Node2D

func flip_sprites():
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			child.flip_h = true


func _ready():
	flip_sprites()
