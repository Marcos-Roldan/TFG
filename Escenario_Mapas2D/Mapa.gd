# Mapa: escenario cerrado de 2000x2000 donde ocurre la partida.
extends Node2D

# Tamaño del mapa (ancho, alto)
@export var tamano: Vector2i = Vector2i(2000, 2000)


# Al arrancar, ajusta la cámara del jugador para que no se vea fuera del mapa.
func _ready():
	# Busca al jugador (su nodo tiene que estar en el grupo "jugador")
	var jugador = get_tree().get_first_node_in_group("jugador")
	# Si todavía no hay jugador, no hace nada
	if jugador == null:
		return
	# Busca la cámara del jugador (tiene que llamarse Camera2D)
	var cam = jugador.get_node_or_null("Camera2D")
	if cam is Camera2D:
		# Pone los límites de la cámara en los bordes del mapa
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = tamano.x
		cam.limit_bottom = tamano.y


# Devuelve un punto aleatorio fuera de la pantalla, para que aparezcan los enemigos.
# Lo usará quien programe las oleadas.
func punto_aparicion(centro: Vector2, distancia: float = 700.0) -> Vector2:
	# Elige una dirección al azar y se aleja esa distancia del centro (el jugador)
	var p = centro + Vector2.RIGHT.rotated(randf() * TAU) * distancia
	# Lo mantiene dentro del mapa
	return p.clamp(Vector2(20, 20), Vector2(tamano) - Vector2(20, 20))
