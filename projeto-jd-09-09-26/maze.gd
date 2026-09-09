extends Node2D
class_name Maze

const CELL_SIZE = 24
const WIDTH = 21 # Deve ser ímpar
const HEIGHT = 21 # Deve ser ímpar

var grid: Array = []

func _ready():
	_generate_grid()
	queue_redraw()

func _generate_grid():
	grid.clear()
	# 1. Inicializa tudo como parede (1)
	for y in HEIGHT:
		var row = []
		for x in WIDTH:
			row.append(1)
		grid.append(row)
	
	# 2. Gera os caminhos usando DFS (Backtracking)
	var visited = []
	for y in HEIGHT:
		var v_row = []
		for x in WIDTH:
			v_row.append(false)
		visited.append(v_row)
		
	_carve_maze(1, 1, visited)
	
	# 3. Limpa a sala central para os fantasmas
	var cx = int(WIDTH / 2)
	var cy = int(HEIGHT / 2)
	for y in range(cy - 1, cy + 2):
		for x in range(cx - 2, cx + 3):
			grid[y][x] = 0
			
	# 4. Preenche os caminhos vazios com pastilhas normais (2)
	# Ignora as bordas e a sala central dos fantasmas
	for y in range(1, HEIGHT - 1):
		for x in range(1, WIDTH - 1):
			# Se for caminho livre e não for a sala central
			if grid[y][x] == 0:
				if x < cx - 2 or x > cx + 2 or y < cy - 1 or y > cy + 1:
					grid[y][x] = 2

	# 5. Adiciona os Power Pellets (3) nas quinas livres
	grid[1][1] = 3
	grid[1][WIDTH - 2] = 3
	grid[HEIGHT - 2][1] = 3
	grid[HEIGHT - 2][WIDTH - 2] = 3

# Algoritmo DFS para escavar o labirinto garantindo caminhos conectados
func _carve_maze(cx: int, cy: int, visited: Array):
	visited[cy][cx] = true
	grid[cy][cx] = 0 # Transforma em caminho
	
	# Direções de movimentação (pula de 2 em 2 células para manter os pilares)
	var dirs = [Vector2i(0, -2), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(2, 0)]
	dirs.shuffle() # Aleatoriedade para criar labirintos diferentes
	
	for d in dirs:
		var nx = cx + d.x
		var ny = cy + d.y
		
		# Verifica se a nova célula está dentro dos limites válidos (ignorando a borda externa)
		if nx > 0 and nx < WIDTH - 1 and ny > 0 and ny < HEIGHT - 1:
			if not visited[ny][nx]:
				# Derruba a parede entre a célula atual e a próxima
				grid[cy + d.y / 2][cx + d.x / 2] = 0
				_carve_maze(nx, ny, visited)

func _draw():
	for y in grid.size():
		for x in grid[y].size():
			var cell = grid[y][x]
			var pos = Vector2(x, y) * CELL_SIZE
			
			if cell == 1:
				draw_rect(Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE)), Color(0.1, 0.1, 0.6))
			elif cell == 2:
				draw_circle(pos + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0), 3, Color.WHITE)
			elif cell == 3:
				draw_circle(pos + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0), 7, Color.WHITE)

func is_wall(cell: Vector2i) -> bool:
	if cell.y < 0 or cell.y >= grid.size():
		return true
	if cell.x < 0 or cell.x >= grid[cell.y].size():
		return true
	return grid[cell.y][cell.x] == 1

func try_eat(cell: Vector2i) -> int:
	if cell.y < 0 or cell.y >= grid.size():
		return 0
	if cell.x < 0 or cell.x >= grid[cell.y].size():
		return 0
	var val = grid[cell.y][cell.x]
	if val == 2 or val == 3:
		grid[cell.y][cell.x] = 0
		queue_redraw()
		return val
	return 0

func pellets_left() -> int:
	var count = 0
	for row in grid:
		for cell in row:
			if cell == 2 or cell == 3:
				count += 1
	return count

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / CELL_SIZE), int(world_pos.y / CELL_SIZE))

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)
