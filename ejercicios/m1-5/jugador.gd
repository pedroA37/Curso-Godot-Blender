extends Area2D
## Ejercicio m1-5: invulnerabilidad con contacto sostenido.
## La consigna completa está en la clase m1-5 de la plataforma, estación «Programar».
## Este archivo es lo único que tienes que modificar.

signal golpeado(vidas)

var vidas := 3
var invulnerable := false


func _on_body_entered(_body: Node2D) -> void:
	pass
