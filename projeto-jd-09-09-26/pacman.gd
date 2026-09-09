extends Node2D
class_name Pacman

const SPEED = 120.0
const CELL_SIZE = 24

var maze: Maze
var current_cell: Vector2i
var direction := Vector2i.ZERO
var next_direction := Vector2i.ZERO
var mouth_open := true
var mouth_timer := 0.0

# chamado pelo main.gd depois de atribuir "maze"
# (NÃO usar _ready aqui: o _ready dos filhos roda antes do _ready do pai)
func initialize():
	current_cell = maze.world_to_cell(position)
	position = maze.cell_to_world(current_cell)

func _process(delta):
	delta = min(delta, 0.05)  # trava pico de lag, evita atravessar parede
	if maze == null:
		return
	_read_input()
	_move(delta)
	_animate_mouth(delta)
	queue_redraw()

# lê as setas do teclado e guarda a direção desejada
func _read_input():
	if Input.is_action_pressed("ui_right"):
		next_direction = Vector2i(1, 0)
	elif Input.is_action_pressed("ui_left"):
		next_direction = Vector2i(-1, 0)
	elif Input.is_action_pressed("ui_up"):
		next_direction = Vector2i(0, -1)
	elif Input.is_action_pressed("ui_down"):
		next_direction = Vector2i(0, 1)

# anda até o centro da PRÓXIMA célula usando move_toward
# (nunca ultrapassa o alvo, por isso nunca atravessa parede)
func _move(delta):
	if direction == Vector2i.ZERO:
		if next_direction != Vector2i.ZERO and not maze.is_wall(current_cell + next_direction):
			direction = next_direction
		return

	var target = maze.cell_to_world(current_cell + direction)
	position = position.move_toward(target, SPEED * delta)

	if position == target:
		current_cell += direction

		var eaten = maze.try_eat(current_cell)
		if eaten == 2:
			GameManager.add_score(10)
		elif eaten == 3:
			GameManager.add_score(50)
			GameManager.start_frightened()

		# troca de direção só é aceita se a próxima célula não for parede
		if next_direction != Vector2i.ZERO and not maze.is_wall(current_cell + next_direction):
			direction = next_direction
		if maze.is_wall(current_cell + direction):
			direction = Vector2i.ZERO

# pisca a "boca" abrindo e fechando
func _animate_mouth(delta):
	mouth_timer += delta
	if mouth_timer > 0.15:
		mouth_timer = 0.0
		mouth_open = not mouth_open

# desenha o círculo amarelo + fatia preta (boca) na direção do movimento
func _draw():
	var radius = CELL_SIZE / 2.0 - 2
	draw_circle(Vector2.ZERO, radius, Color.YELLOW)

	if mouth_open and direction != Vector2i.ZERO:
		var angle = Vector2(direction).angle()
		var wedge = PackedVector2Array([
			Vector2.ZERO,
			Vector2(radius * 2, 0).rotated(angle - 0.4),
			Vector2(radius * 2, 0).rotated(angle + 0.4)
		])
		# cor igual ao fundo simula a "boca" aberta
		draw_colored_polygon(wedge, Color.BLACK)
