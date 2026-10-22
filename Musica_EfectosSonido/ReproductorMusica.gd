# ReproductorMusica: se encarga de que se escuche la música y los efectos de sonido del juego.
extends Node

# Carpeta donde están los efectos de sonido 
const RUTA_SFX := "res://Musica_EfectosSonido/efectosSonido/"
# Carpeta donde está la música de fondo 
const RUTA_MUSICA := "res://Musica_EfectosSonido/musica/"

# Reproductor que se usa solo para la música de fondo
var music_player := AudioStreamPlayer.new()
# Diccionario donde se guardan los sonidos ya cargados, para no cargarlos cada vez
var cache := {}


# Se ejecuta una sola vez, al arrancar el juego.
func _ready():
	# Crea los dos canales de audio: uno para música y otro para efectos.
	# Sirven para poder subir o bajar el volumen de cada uno por separado.
	_crear_bus("Music")
	_crear_bus("SFX")
	# Le dice al reproductor de música que use el canal "Music"
	music_player.bus = "Music"
	# Añade el reproductor al juego para que pueda sonar
	add_child(music_player)


# Crea un canal de audio con el nombre que le pases, solo si todavía no existe.
func _crear_bus(nombre: String):
	# Si no existe un canal con ese nombre (devuelve -1)
	if AudioServer.get_bus_index(nombre) == -1:
		# ...crea un canal nuevo
		AudioServer.add_bus()
		# Guarda la posición del canal que acaba de crear (el último)
		var i = AudioServer.bus_count - 1
		# Le pone el nombre
		AudioServer.set_bus_name(i, nombre)
		# Lo conecta al canal principal para que se escuche
		AudioServer.set_bus_send(i, "Master")


# Carga un archivo de sonido desde una ruta y lo guarda en memoria.
# Si el archivo no existe, avisa en la consola y devuelve null 
func _cargar(ruta: String) -> AudioStream:
	# Si todavía no se ha cargado este sonido
	if not cache.has(ruta):
		# lo carga si existe, y si no existe guarda null
		cache[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
		# Si no se ha podido cargar, avisa en la consola 
		if cache[ruta] == null:
			push_warning("ReproductorMusica: no existe " + ruta)
	# Devuelve el sonido cargado
	return cache[ruta]


# Reproduce un efecto de sonido por su nombre 
func play_sfx(nombre: String):
	# Busca y carga el archivo de la carpeta sfx
	var s = _cargar(RUTA_SFX + nombre + ".wav")
	# Si no existe, no hace nada y sale de la función
	if s == null:
		return
	# Crea un reproductor nuevo solo para este sonido.
	# Así pueden sonar varios efectos a la vez sin cortarse entre sí.
	var p := AudioStreamPlayer.new()
	# Le asigna el sonido
	p.stream = s
	# Lo manda al canal de efectos
	p.bus = "SFX"
	# Lo añade al juego
	add_child(p)
	# Cuando el sonido termine, el reproductor se borra solo para no acumular basura
	p.finished.connect(p.queue_free)
	# Lo reproduce
	p.play()


# Reproduce la música de fondo por su nombre 
func play_music(nombre: String):
	# Busca y carga el archivo de la carpeta musica
	var s = _cargar(RUTA_MUSICA + nombre + ".ogg")
	# Si no existe, no hace nada
	if s == null:
		return
	# Si esa canción ya está sonando, no la reinicia
	if music_player.stream == s and music_player.playing:
		return
	# Le asigna la canción al reproductor
	music_player.stream = s
	# La reproduce
	music_player.play()


# Para la música de fondo (por ejemplo, al salir al menú).
func stop_music():
	music_player.stop()


# Cambia el volumen de la música. Se usa en el menú de Ajustes.
# El valor va de 0.0 (silencio) a 1.0 (volumen máximo).
func set_volumen_musica(v: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))


# Cambia el volumen de los efectos de sonido. También para el menú de Ajustes.
func set_volumen_sfx(v: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))
