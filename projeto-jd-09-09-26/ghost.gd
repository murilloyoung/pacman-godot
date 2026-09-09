extends Node2D
class_name Ghost

const SPEED = 100.0
const CELL_SIZE = 24

@export var color: Color = Color.RED

var maze: Maze
var pacman: Pacman
var current_cell: Vector2i
var direction := Vector2i.ZERO
var frightened := false

# chamado pelo main.gd depois de atribuir "maze" e "pacman"
func initialize():
	current_cell = maze.world_to_cell(position)
	position = maze.cell_to_world(current_cell)
	_pick_direction()

func _process(delta):
	delta = min(delta, 0.05)  # mesma trava de segurança do Pacman
	if maze == null:
		return
	_move(delta)
	queue_redraw()

# anda até o centro da próxima célula; ao chegar, escolhe pra onde ir
func _move(delta):
	var target = maze.cell_to_world(current_cell + direction)
	position = position.move_toward(target, SPEED * delta)
	if position == target:
		current_cell += direction
		_pick_direction()

# decide a próxima direção: persegue o Pacman (normal) ou anda
# aleatório (assustado), nunca voltando pra célula anterior à toa
func _pick_direction():
	var options: Array = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if d == -direction:
			continue
		if not maze.is_wall(current_cell + d):
			options.append(d)

	if options.is_empty():
		direction = -direction
		return

	if frightened or pacman == null:
		direction = options[randi() % options.size()]
		return

	# perseguição simples: escolhe a direção que mais aproxima do Pacman
	var target_cell = maze.world_to_cell(pacman.position)
	var best = options[0]
	var best_dist = INF
	for d in options:
		var dist = (current_cell + d).distance_to(Vector2(target_cell))
		if dist < best_dist:
			best_dist = dist
			best = d
	direction = best

func set_frightened(value: bool):
	frightened = value

# desenha um círculo colorido; fica azul enquanto assustado
func _draw():
	var radius = CELL_SIZE / 2.0 - 2
	var c = Color.BLUE if frightened else color
	draw_circle(Vector2.ZERO, radius, c)
