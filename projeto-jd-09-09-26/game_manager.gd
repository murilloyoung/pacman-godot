extends Node

signal score_changed(new_score)
signal frightened_ended
signal game_over
signal game_won

var score := 0
var lives := 3
var frightened_time := 6.0
var frightened_timer := 0.0
var is_frightened := false

# conta regressiva do modo "assustado" (depois de comer power pellet)
func _process(delta):
	if is_frightened:
		frightened_timer -= delta
		if frightened_timer <= 0:
			is_frightened = false
			emit_signal("frightened_ended")

func add_score(amount: int):
	score += amount
	emit_signal("score_changed", score)

func start_frightened():
	is_frightened = true
	frightened_timer = frightened_time

func lose_life():
	lives -= 1
	if lives <= 0:
		emit_signal("game_over")
