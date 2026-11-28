extends Node2D

@export var velocidad = 2

func _process(delta):
	rotation += velocidad * delta
