extends Area2D

var campanadas := 0

func _on_body_entered(body):
	campanadas += 1
	$AudioStreamPlayer2D.play()
	print("campanadas: ", campanadas)
