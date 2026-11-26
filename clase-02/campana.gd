extends Area2D

## Avisa cada campanada. La campana no sabe quién escucha.
signal sono(campanadas: int)

var campanadas := 0

func _on_body_entered(_body):
	campanadas += 1
	$AudioStreamPlayer2D.play()
	sono.emit(campanadas)
