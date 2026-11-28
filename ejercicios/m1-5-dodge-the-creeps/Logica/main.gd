extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	new_game()
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_enemigos_timeout() -> void:
	var mob = mob_scene.instantiate()

	var mob_spawn_location = $enemigosPath/PathFollow2D
	mob_spawn_location.progress_ratio = randf()
	
	mob.position = mob_spawn_location.position

	var direction = mob_spawn_location.rotation + PI / 2

	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)


func _on_puntaje_timeout() -> void:
	score += 1


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
