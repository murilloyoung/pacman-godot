extends Node2D

var maze: Maze
var pacman: Pacman
var ghosts: Array = []
var invulnerable := false
var invulnerable_timer := 0.0

func _ready():
	maze = $Maze
	pacman = $Pacman
	pacman.maze = maze
	pacman.initialize()

	for ghost in $Ghosts.get_children():
		ghost.maze = maze
		ghost.pacman = pacman
		ghost.initialize()
		ghosts.append(ghost)

	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over.connect(_on_game_over)

	if has_node("UI/ScoreLabel"):
		$UI/ScoreLabel.add_theme_font_size_override("font_size", 24)
	_on_score_changed(GameManager.score)

# a cada frame: atualiza modo assustado dos fantasmas e checa colisão
func _process(delta):
	if invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			invulnerable = false

	for ghost in ghosts:
		ghost.set_frightened(GameManager.is_frightened)
		if ghost.current_cell == pacman.current_cell:
			if GameManager.is_frightened:
				# Pacman "come" o fantasma: ele volta pro centro
				ghost.position = maze.cell_to_world(Vector2i(10, 10))
				GameManager.add_score(200)
			elif not invulnerable:
				# perde 1 vida e fica 1.5s protegido antes de poder perder outra
				GameManager.lose_life()
				pacman.position = maze.cell_to_world(Vector2i(10, 19))
				invulnerable = true
				invulnerable_timer = 1.5

	if maze.pellets_left() == 0:
		GameManager.emit_signal("game_won")

func _on_score_changed(new_score):
	if has_node("UI/ScoreLabel"):
		$UI/ScoreLabel.text = "Pontuação: %d" % new_score

func _on_game_over():
	print("Game Over")
	get_tree().paused = true
